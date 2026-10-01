

with months as (

    select distinct month_start_date
    from "saas_dw"."core"."dim_date"

),

features as (

    

    select feature_name
    from (
        
        select cast('core' as varchar) as feature_name
        union all
        
        select cast('core_dashboard' as varchar) as feature_name
        union all
        
        select cast('data_export' as varchar) as feature_name
        union all
        
        select cast('api_access' as varchar) as feature_name
        union all
        
        select cast('sso' as varchar) as feature_name
        union all
        
        select cast('audit_log' as varchar) as feature_name
        union all
        
        select cast('advanced_analytics' as varchar) as feature_name
        
        
    ) as enumerated

),

feature_tiers as (

    

    select feature_name, min_tier_rank
    from (
        
        select
            cast('core' as varchar) as feature_name,
            cast(0 as integer)          as min_tier_rank
        union all
        
        select
            cast('core_dashboard' as varchar) as feature_name,
            cast(1 as integer)          as min_tier_rank
        union all
        
        select
            cast('data_export' as varchar) as feature_name,
            cast(2 as integer)          as min_tier_rank
        union all
        
        select
            cast('api_access' as varchar) as feature_name,
            cast(2 as integer)          as min_tier_rank
        union all
        
        select
            cast('sso' as varchar) as feature_name,
            cast(3 as integer)          as min_tier_rank
        union all
        
        select
            cast('audit_log' as varchar) as feature_name,
            cast(3 as integer)          as min_tier_rank
        union all
        
        select
            cast('advanced_analytics' as varchar) as feature_name,
            cast(4 as integer)          as min_tier_rank
        
        
    ) as enumerated

),

plans as (

    select * from "saas_dw"."core"."dim_plans"

),

-- The denominator: accounts that occupied each plan at any point in each month. Derived from
-- subscription terms rather than from the month-end fact, so it uses the same per-event
-- attribution as the numerator. An account that upgrades mid-month is a candidate for both the
-- tier it left and the tier it joined, which is exactly right: it could have generated events
-- on either.
account_base as (

    select
        months.month_start_date,
        terms.plan_code,
        count(distinct terms.account_id)  as eligible_accounts

    from "saas_dw"."staging"."stg_subscriptions" as terms
    inner join months
        on  months.month_start_date >= terms.term_start_month
        and months.month_start_date <= coalesce(
                date_trunc('month', terms.term_end_at)::date,
                (select max(month_start_date) from months)
            )

    group by months.month_start_date, terms.plan_code

),

-- The term in force at the moment of the event. Terms are contiguous and non-overlapping, so
-- exactly one matches.
attributed_usage as (

    select
        date_trunc('month', events.event_date)::date    as month_start_date,
        terms.plan_code,
        events.feature,
        count(*)                                       as feature_event_count,
        count(distinct events.account_id)              as accounts_using_feature,
        count(distinct events.user_id)                 as feature_active_users,
        count(distinct events.session_id)              as feature_session_count

    from "saas_dw"."core"."fct_product_events" as events
    inner join "saas_dw"."staging"."stg_subscriptions" as terms
        on  terms.account_id = events.account_id
       and terms.term_start_at <= events.event_ts
       and (terms.term_end_at is null or events.event_ts < terms.term_end_at)

    group by 1, 2, 3

),

grid as (

    select
        months.month_start_date,
        features.feature_name                                as feature,
        plans.plan_code,
        plans.tier_rank,
        feature_tiers.min_tier_rank,
        coalesce(account_base.eligible_accounts, 0)          as eligible_accounts,
        coalesce(attributed_usage.accounts_using_feature, 0) as accounts_using_feature,
        coalesce(attributed_usage.feature_event_count, 0)     as feature_event_count,
        coalesce(attributed_usage.feature_active_users, 0)   as feature_active_users,
        coalesce(attributed_usage.feature_session_count, 0)   as feature_session_count

    from months
    cross join features
    cross join plans
    left join feature_tiers
        on feature_tiers.feature_name = features.feature_name
    left join account_base
        on  account_base.month_start_date = months.month_start_date
        and account_base.plan_code = plans.plan_code
    left join attributed_usage
        on  attributed_usage.month_start_date = months.month_start_date
        and attributed_usage.plan_code = plans.plan_code
        and attributed_usage.feature = features.feature_name

),

-- Split out because entitled_accounts is referenced by the rates below, and a select list
-- cannot reference an alias defined in the same select list.
scored as (

    select
        md5(cast(coalesce(cast(grid.month_start_date as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(grid.feature as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(grid.plan_code as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                                as sk_feature_adoption,
        -- dim_date also exposes a month_start_date column, so every column coming out of the
        -- grid has to be qualified.
        grid.month_start_date,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        grid.feature,
        grid.plan_code,
        grid.tier_rank,
        grid.min_tier_rank,

        (grid.min_tier_rank = 0)                            as is_ungated_feature,
        (grid.tier_rank >= grid.min_tier_rank)               as is_plan_entitled,

        grid.eligible_accounts,
        -- Zero rather than null when the tier cannot reach the feature: the tier is not a
        -- candidate, and a null would be averaged into the rate as though it were.
        case
            when grid.tier_rank >= grid.min_tier_rank then grid.eligible_accounts
            else 0
        end                                                 as entitled_accounts,
        grid.accounts_using_feature,
        grid.feature_event_count,
        grid.feature_active_users,
        grid.feature_session_count

    from grid
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = grid.month_start_date

)

select
    *,

    -- Adoption across everyone who occupied the tier that month.
    cast(accounts_using_feature as numeric)
        / nullif(cast(eligible_accounts as numeric), 0)  as adoption_rate,

    -- Adoption across the accounts that could actually reach it. NULL when nobody on the tier
    -- is entitled, because the question does not apply there.
    cast(accounts_using_feature as numeric)
        / nullif(cast(entitled_accounts as numeric), 0) as entitled_adoption_rate,

    (entitled_accounts - accounts_using_feature)             as entitled_not_adopting,

    cast(feature_event_count as numeric)
        / nullif(cast(accounts_using_feature as numeric), 0)
                                                            as events_per_adopting_account,

    cast(feature_active_users as numeric)
        / nullif(cast(accounts_using_feature as numeric), 0)
                                                            as users_per_adopting_account

from scored


with events as (

    select * from "saas_dw"."core"."fct_product_events"

),

weekly as (

    select
        account_id,
        week_start_date,

        count(*)                                            as event_count,
        count(distinct session_id)                          as session_count,
        count(distinct user_id)                             as active_user_count,
        count(distinct feature)                             as distinct_feature_count,
        count(distinct feature) filter (where is_gated_feature) as gated_feature_count,
        count(*) filter (where is_api_event)                as api_event_count,

        min(event_ts)                                       as first_event_at,
        max(event_ts)                                       as last_event_at

    from events
    group by account_id, week_start_date

),

with_calendar as (

    select
        weekly.*,
        md5(cast(coalesce(cast(weekly.account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))  as fk_account,
        md5(cast(coalesce(cast(weekly.week_start_date as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_date,

        dim_date.day_of_week,
        dim_date.week_of_year,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        date_trunc('month', weekly.week_start_date)::date as month_start_date

    from weekly
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = weekly.week_start_date

),

final as (

    select
        md5(cast(coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(week_start_date as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                            as sk_account_week,
        fk_account,
        account_id,
        fk_date,
        week_start_date,
        week_of_year,
        month_start_date,
        month_year,
        year_number,
        quarter_number,

        event_count,
        session_count,
        active_user_count,
        distinct_feature_count,
        gated_feature_count,
        api_event_count,
        first_event_at,
        last_event_at,

        -- Engagement per head, which normalises away the fact that a 5000-seat account
        -- generates more raw events than a 10-seat one.
        cast(event_count as numeric)
        / nullif(cast(active_user_count as numeric), 0)          as events_per_active_user,
        cast(event_count as numeric)
        / nullif(cast(session_count as numeric), 0)              as events_per_session,
        cast(api_event_count as numeric)
        / nullif(cast(event_count as numeric), 0)           as api_event_share,

        -- Sessions and events both present means the account was genuinely used, not
        -- just pinged once.
        (session_count > 0 and event_count > 0)                        as is_active_week

    from with_calendar

)

select * from final
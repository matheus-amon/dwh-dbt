
  
    

  create  table "saas_dw"."core"."fct_subscription_periods__dbt_tmp"
  
  
    as
  
  (
    
with months as (

    select distinct month_start_date
    from "saas_dw"."core"."dim_date"

),

window_end as (

    select max(month_start_date) as month_start_date
    from months

),

terms as (

    select * from "saas_dw"."staging"."stg_subscriptions"

),

expanded as (

    select
        terms.account_id,
        terms.subscription_id,
        terms.plan_code,
        terms.seats,
        terms.discount_pct,
        terms.mrr_usd,
        terms.term_start_at,
        terms.term_end_at,
        terms.is_upgrade,
        terms.is_downgrade,
        terms.is_churn,
        months.month_start_date

    from terms
    inner join months
        on months.month_start_date >= terms.term_start_month
       and months.month_start_date <= coalesce(
               date_trunc('month', terms.term_end_at)::date,
               (select month_start_date from window_end)
           )

),

ranked as (

    select
        expanded.*,

        -- The term in force at month end: the latest one to have started this month.
        row_number() over (
            partition by account_id, month_start_date
            order by term_start_at desc, subscription_id desc
        )                                                           as term_rank,

        count(*) over (
            partition by account_id, month_start_date
        )                                                           as terms_in_month,

        -- Whether a term that closed *inside this month* was an upgrade, a downgrade or a
        -- churn. These are attributes of the term, so they must be attributed to the month
        -- the term ended in — a term that churned in May did not churn in every month it
        -- spanned.
        max(case
                when is_upgrade and date_trunc('month', term_end_at)::date = month_start_date
                then 1 else 0 end) over (partition by account_id, month_start_date) as had_upgrade,

        max(case
                when is_downgrade and date_trunc('month', term_end_at)::date = month_start_date
                then 1 else 0 end) over (partition by account_id, month_start_date) as had_downgrade,

        max(case
                when is_churn and date_trunc('month', term_end_at)::date = month_start_date
                then 1 else 0 end) over (partition by account_id, month_start_date) as had_churn

    from expanded

),

month_end_state as (

    select
        account_id,
        month_start_date,
        subscription_id,
        plan_code,
        seats,
        discount_pct,
        mrr_usd,
        term_start_at,
        term_end_at,
        terms_in_month,
        had_upgrade,
        had_downgrade,
        had_churn

    from ranked
    where term_rank = 1

),

with_prior as (

    select
        *,

        lag(mrr_usd) over (
            partition by account_id order by month_start_date
        )                                                           as prior_mrr_usd,

        lag(plan_code) over (
            partition by account_id order by month_start_date
        )                                                           as prior_plan_code,

        row_number() over (
            partition by account_id order by month_start_date
        )                                                           as tenure_month_number

    from month_end_state

),

with_calendar as (

    select
        with_prior.*,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        dim_date.month_number

    from with_prior
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = with_prior.month_start_date

),

final as (

    select
        md5(cast(coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(month_start_date as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                                                            as sk_subscription_period,
        md5(cast(coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_account,
        account_id,
        subscription_id,
        month_start_date,
        month_year,
        year_number,
        quarter_number,
        month_number,
        tenure_month_number,
        md5(cast(coalesce(cast(plan_code as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))  as fk_plan,
        plan_code,
        prior_plan_code,
        seats,
        discount_pct,
        mrr_usd,
        prior_mrr_usd,
        (mrr_usd - prior_mrr_usd)                              as mrr_change_usd,
        terms_in_month,
        had_upgrade,
        had_downgrade,
        had_churn,

        (prior_mrr_usd is null)                                as is_first_month,
        (prior_mrr_usd is null)                                as is_new_account,
        (terms_in_month > 1)                                   as is_plan_change_month,
        (terms_in_month > 1 and had_upgrade = 1)              as is_plan_upgrade,
        (terms_in_month > 1 and had_downgrade = 1)            as is_plan_downgrade,
        (had_churn = 1)                                        as is_churned_month,

        -- A month that churned is excluded from expansion and contraction. If an account upgrades
        -- and churns in the same month, its MRR at month end is leaving the business, so
        -- crediting an expansion that never materialises would inflate the movement mart.
        case
            when prior_mrr_usd is null                then false
            when had_churn = 1                        then false
            when mrr_usd > prior_mrr_usd              then true
            else false
        end                                                   as is_expansion,

        case
            when prior_mrr_usd is null                then false
            when had_churn = 1                        then false
            when mrr_usd < prior_mrr_usd              then true
            else false
        end                                                   as is_contraction

    from with_calendar

)

select * from final
  );
  

  
    

  create  table "saas_dw"."marts"."mart_cohort_retention__dbt_tmp"
  
  
    as
  
  (
    

with periods as (

    select * from "saas_dw"."core"."fct_subscription_periods"

),

accounts as (

    select
        account_id,
        signup_month,
        plan_code_at_signup,
        employee_band,
        region

    from "saas_dw"."core"."dim_accounts"

),

cohorted as (

    select
        periods.*,
        accounts.signup_month,
        accounts.plan_code_at_signup,
        accounts.employee_band,
        accounts.region

    from periods
    inner join accounts using (account_id)

),

-- The cohort as it was on arrival: how many accounts signed up, and at what MRR.
cohort_entry as (

    select
        signup_month,
        plan_code_at_signup,
        count(distinct account_id)            as cohort_accounts,
        sum(mrr_usd)                         as cohort_entry_mrr_usd

    from cohorted
    where tenure_month_number = 1
    group by signup_month, plan_code_at_signup

),

cohort_extent as (

    select
        signup_month,
        plan_code_at_signup,
        max(tenure_month_number)             as max_observed_months

    from cohorted
    group by signup_month, plan_code_at_signup

),

by_period as (

    select
        signup_month,
        plan_code_at_signup,
        tenure_month_number,
        count(*) filter (where not is_churned_month)             as retained_accounts,
        sum(case when not is_churned_month then mrr_usd else 0 end) as retained_mrr_usd,
        sum(case when is_expansion then mrr_change_usd else 0 end)  as expansion_mrr_usd,
        sum(case when is_contraction then -mrr_change_usd else 0 end) as contraction_mrr_usd,
        count(*) filter (where is_churned_month)                 as churned_accounts_in_period

    from cohorted
    group by signup_month, plan_code_at_signup, tenure_month_number

),

with_prior as (

    select
        by_period.*,
        lag(retained_accounts) over (
            partition by signup_month, plan_code_at_signup order by tenure_month_number
        )                                                          as prior_retained_accounts

    from by_period

),

final as (

    select
        with_prior.signup_month,
        with_prior.plan_code_at_signup,
        dim_date.month_year                                as cohort_month_year,
        with_prior.tenure_month_number,
        (with_prior.tenure_month_number - 1)               as months_since_signup,

        cohort_entry.cohort_accounts,
        cohort_entry.cohort_entry_mrr_usd,
        cohort_extent.max_observed_months,

        with_prior.retained_accounts,
        with_prior.retained_mrr_usd,
        with_prior.prior_retained_accounts,
        with_prior.churned_accounts_in_period,

        -- Share of the cohort still paying at the end of this period.
        cast(with_prior.retained_accounts as numeric)
        / nullif(cast(cohort_entry.cohort_accounts as numeric), 0)
                                                            as account_retention_rate,

        -- Index of retained MRR against the cohort's opening MRR, NOT a retention rate. A
        -- cohort that expands after signing up holds more revenue than it arrived with, so
        -- this legitimately exceeds 1 — that is net revenue retention, and calling it a rate
        -- would invite exactly the wrong reading.
        cast(with_prior.retained_mrr_usd as numeric)
        / nullif(cast(cohort_entry.cohort_entry_mrr_usd as numeric), 0)
                                                            as mrr_retention_index,

        (cohort_entry.cohort_accounts - with_prior.retained_accounts)
                                                            as churned_accounts_cumulative,

        1 - cast(with_prior.retained_accounts as numeric)
        / nullif(cast(cohort_entry.cohort_accounts as numeric), 0)
                                                            as cumulative_account_churn_rate,

        -- Movement against the previous period of the same cohort.
        (with_prior.retained_accounts - coalesce(with_prior.prior_retained_accounts, 0))
                                                            as retained_accounts_change,

        with_prior.expansion_mrr_usd,
        with_prior.contraction_mrr_usd

    from with_prior
    inner join cohort_entry
        on  cohort_entry.signup_month = with_prior.signup_month
        and cohort_entry.plan_code_at_signup = with_prior.plan_code_at_signup
    inner join cohort_extent
        on  cohort_extent.signup_month = with_prior.signup_month
        and cohort_extent.plan_code_at_signup = with_prior.plan_code_at_signup
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = with_prior.signup_month

)

select * from final
  );
  
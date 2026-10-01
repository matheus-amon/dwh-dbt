-- Every period of a cohort must run from 1 up to the cohort's own extent, with no gaps and no
-- duplicates. A missing period means an account vanished from the fact without churning, which
-- would silently flatten the retention curve.
with bounds as (

    select
        signup_month,
        plan_code_at_signup,
        min(tenure_month_number) as min_tenure,
        max(tenure_month_number) as max_tenure,
        count(*)                 as periods_present,
        count(distinct tenure_month_number) as distinct_periods,
        max(max_observed_months) as max_observed_months

    from "saas_dw"."marts"."mart_cohort_retention"
    group by signup_month, plan_code_at_signup

)

select *
from bounds
where min_tenure <> 1
   or max_tenure <> max_observed_months
   or periods_present <> distinct_periods
   or distinct_periods <> max_observed_months
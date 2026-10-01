

with meet_condition as(
  select *
  from (select * from "saas_dw"."staging"."stg_accounts" where is_churned) dbt_subquery
),

validation_errors as (
  select *
  from meet_condition
  where
    -- never true, defaults to an empty result set. Exists to ensure any combo of the `or` clauses below succeeds
    1 = 2
    -- records with a value >= min_value are permitted. The `not` flips this to find records that don't meet the rule.
    or not churned_at > 0
)

select *
from validation_errors


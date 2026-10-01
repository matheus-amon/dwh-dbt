



select
    *
from (select * from "saas_dw"."staging"."stg_accounts" where is_churned) dbt_subquery

where not(churned_at > '2000-01-01')


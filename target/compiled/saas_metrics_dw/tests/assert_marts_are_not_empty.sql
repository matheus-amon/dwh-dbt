-- A mart that builds successfully but contains nothing is the failure mode unit tests and
-- compile checks do not catch. Every mart must have rows.
with row_counts as (

    select 'mart_mrr_movement'    as mart, count(*) as rows from "saas_dw"."marts"."mart_mrr_movement"
    union all
    select 'mart_cohort_retention', count(*) from "saas_dw"."marts"."mart_cohort_retention"
    union all
    select 'mart_product_adoption', count(*) from "saas_dw"."marts"."mart_product_adoption"
    union all
    select 'mart_account_health',   count(*) from "saas_dw"."marts"."mart_account_health"

)

select mart, rows
from row_counts
where rows = 0
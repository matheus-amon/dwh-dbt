-- The MRR movement buckets must reconcile: opening balance plus net new must equal the
-- closing balance, exactly. This is the cheapest possible proof that the buckets are
-- complete and non-overlapping — a missing or double-counted movement shows up here as a
-- rounding-level discrepancy instead of silently skewing every downstream report.
select
    month_start_date,
    beginning_mrr_usd,
    net_new_mrr_usd,
    ending_mrr_usd,
    (beginning_mrr_usd + net_new_mrr_usd) - ending_mrr_usd as discrepancy_usd

from "saas_dw"."marts"."mart_mrr_movement"

where abs((beginning_mrr_usd + net_new_mrr_usd) - ending_mrr_usd) > 0.005
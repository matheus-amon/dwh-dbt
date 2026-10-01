-- Movement flags must not overlap. The movement mart buckets MRR by these booleans, so if a
-- month could be both an expansion and a contraction the buckets would not add up to net
-- new MRR. A churn month is never an expansion either: the account's MRR is leaving, not
-- growing.
select *
from "saas_dw"."core"."fct_subscription_periods"
where (is_expansion and is_contraction)
   or (is_churned_month and is_expansion)
   or (is_churned_month and is_new_account and mrr_change_usd <> 0)
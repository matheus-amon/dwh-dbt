-- Churned MRR is taken from the account's opening balance, so every churn month must have
-- one. An account cannot churn in its first month — there is nothing in the opening balance
-- to remove — and if that ever happened the movement mart would silently drop the revenue
-- instead of failing.
select *
from "saas_dw"."core"."fct_subscription_periods"
where is_churned_month
  and prior_mrr_usd is null
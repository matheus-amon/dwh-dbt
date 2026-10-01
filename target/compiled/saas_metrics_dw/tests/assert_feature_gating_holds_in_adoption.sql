-- A plan tier must never show usage of a feature it is not entitled to. This is the invariant
-- that lets the adoption mart distinguish "nobody adopted it" from "nobody could reach it": if
-- it broke, a gated feature's low adoption on small tiers would be a real finding rather than
-- an artefact.
select *
from "saas_dw"."marts"."mart_product_adoption"
where not is_plan_entitled
  and (accounts_using_feature > 0 or feature_event_count > 0 or entitled_accounts <> 0)
-- The health score and each of its components are on a 0-100 scale by construction. A score
-- outside that range means the weights or the components were rescaled by accident — which is
-- how every account ended up looking 'healthy' when the real score was ten times too high.
select *
from "saas_dw"."marts"."mart_account_health"
where health_score       < 0 or health_score       > 100
   or recency_score      < 0 or recency_score      > 100
   or frequency_score    < 0 or frequency_score    > 100
   or trend_score        < 0 or trend_score        > 100
   or magnitude_score    < 0 or magnitude_score    > 100
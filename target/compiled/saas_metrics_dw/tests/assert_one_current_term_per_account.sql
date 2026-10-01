-- Every account has exactly one open subscription term. More than one would double-count MRR
-- in the movement mart; none would drop the account out of the fact entirely.
select account_id
from "saas_dw"."staging"."stg_subscriptions"
group by account_id
having count(*) filter (where is_current_term) <> 1
-- Every account has exactly one user flagged as admin. The generator guarantees this, and the
-- warehouse depends on it: role-based analyses and the admin-as-a-proxy-for-buying-signal
-- logic both read is_admin.
select account_id
from "saas_dw"."staging"."stg_users"
group by account_id
having count(*) filter (where is_admin) <> 1
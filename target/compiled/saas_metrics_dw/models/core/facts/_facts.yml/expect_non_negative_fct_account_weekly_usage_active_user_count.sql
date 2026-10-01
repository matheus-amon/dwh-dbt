



select active_user_count
from "saas_dw"."core"."fct_account_weekly_usage"
where active_user_count < 0


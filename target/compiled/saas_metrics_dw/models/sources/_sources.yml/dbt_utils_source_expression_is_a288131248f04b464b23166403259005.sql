



select
    *
from "saas_dw"."raw"."raw_accounts"

where not(country_code length(country_code) = 2)


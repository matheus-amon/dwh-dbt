





with validation_errors as (

    select
        tier_rank
    from "saas_dw"."staging"."stg_plans"
    group by tier_rank
    having count(*) > 1

)

select *
from validation_errors



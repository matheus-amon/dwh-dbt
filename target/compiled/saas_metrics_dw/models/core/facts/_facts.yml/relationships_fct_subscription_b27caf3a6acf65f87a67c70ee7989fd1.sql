
    
    

with child as (
    select plan_code as from_field
    from "saas_dw"."core"."fct_subscription_periods"
    where plan_code is not null
),

parent as (
    select plan_code as to_field
    from "saas_dw"."core"."dim_plans"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



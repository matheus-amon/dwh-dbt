
    
    

with child as (
    select fk_plan as from_field
    from "saas_dw"."core"."fct_subscription_periods"
    where fk_plan is not null
),

parent as (
    select sk_plan as to_field
    from "saas_dw"."core"."dim_plans"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



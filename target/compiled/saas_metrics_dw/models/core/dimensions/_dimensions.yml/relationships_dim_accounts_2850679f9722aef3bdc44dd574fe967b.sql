
    
    

with child as (
    select plan_code_at_signup as from_field
    from "saas_dw"."core"."dim_accounts"
    where plan_code_at_signup is not null
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




    
    

with child as (
    select account_id as from_field
    from "saas_dw"."core"."fct_subscription_periods"
    where account_id is not null
),

parent as (
    select account_id as to_field
    from "saas_dw"."core"."dim_accounts"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



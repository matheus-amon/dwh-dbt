
    
    

with child as (
    select fk_account as from_field
    from "saas_dw"."core"."fct_account_weekly_usage"
    where fk_account is not null
),

parent as (
    select sk_account as to_field
    from "saas_dw"."core"."dim_accounts"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



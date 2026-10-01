
    
    

with child as (
    select fk_date as from_field
    from "saas_dw"."core"."fct_product_events"
    where fk_date is not null
),

parent as (
    select sk_date as to_field
    from "saas_dw"."core"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



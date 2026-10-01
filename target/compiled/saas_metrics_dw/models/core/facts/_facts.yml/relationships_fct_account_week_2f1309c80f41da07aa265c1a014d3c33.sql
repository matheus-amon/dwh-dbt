
    
    

with child as (
    select week_start_date as from_field
    from "saas_dw"."core"."fct_account_weekly_usage"
    where week_start_date is not null
),

parent as (
    select date_day as to_field
    from "saas_dw"."core"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null




    
    

with all_values as (

    select
        is_plan_entitled as value_field,
        count(*) as n_records

    from "saas_dw"."marts"."mart_product_adoption"
    group by is_plan_entitled

)

select *
from all_values
where value_field not in (
    'True','False'
)



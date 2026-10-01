
    
    

with all_values as (

    select
        platform as value_field,
        count(*) as n_records

    from "saas_dw"."staging"."stg_product_events"
    group by platform

)

select *
from all_values
where value_field not in (
    'web','ios','android','api'
)



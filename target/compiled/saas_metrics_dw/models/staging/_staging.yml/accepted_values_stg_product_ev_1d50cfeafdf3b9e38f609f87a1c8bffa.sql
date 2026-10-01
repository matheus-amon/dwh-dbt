
    
    

with all_values as (

    select
        is_gated_feature as value_field,
        count(*) as n_records

    from "saas_dw"."staging"."stg_product_events"
    group by is_gated_feature

)

select *
from all_values
where value_field not in (
    'True','False'
)



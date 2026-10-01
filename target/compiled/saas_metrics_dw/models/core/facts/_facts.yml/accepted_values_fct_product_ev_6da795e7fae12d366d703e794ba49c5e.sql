
    
    

with all_values as (

    select
        feature as value_field,
        count(*) as n_records

    from "saas_dw"."core"."fct_product_events"
    group by feature

)

select *
from all_values
where value_field not in (
    'core','core_dashboard','data_export','api_access','sso','audit_log','advanced_analytics'
)



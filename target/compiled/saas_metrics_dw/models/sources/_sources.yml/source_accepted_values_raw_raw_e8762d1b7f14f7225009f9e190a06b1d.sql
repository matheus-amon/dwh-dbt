
    
    

with all_values as (

    select
        country_code as value_field,
        count(*) as n_records

    from "saas_dw"."raw"."raw_product_events"
    group by country_code

)

select *
from all_values
where value_field not in (
    'US','CA','GB','DE','NL','SE','IE','BR','MX','SG','AU','JP'
)



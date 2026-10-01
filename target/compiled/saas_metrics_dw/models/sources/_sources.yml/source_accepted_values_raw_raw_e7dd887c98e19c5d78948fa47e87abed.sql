
    
    

with all_values as (

    select
        region as value_field,
        count(*) as n_records

    from "saas_dw"."raw"."raw_accounts"
    group by region

)

select *
from all_values
where value_field not in (
    'North America','EMEA','LATAM','APAC'
)




    
    

with all_values as (

    select
        billing_interval as value_field,
        count(*) as n_records

    from "saas_dw"."staging"."stg_plans"
    group by billing_interval

)

select *
from all_values
where value_field not in (
    'monthly','annual'
)



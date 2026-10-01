
    
    

with all_values as (

    select
        is_contraction as value_field,
        count(*) as n_records

    from "saas_dw"."core"."fct_subscription_periods"
    group by is_contraction

)

select *
from all_values
where value_field not in (
    'True','False'
)



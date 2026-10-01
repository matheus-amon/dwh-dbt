
    
    

with all_values as (

    select
        is_churned_month as value_field,
        count(*) as n_records

    from "saas_dw"."core"."fct_subscription_periods"
    group by is_churned_month

)

select *
from all_values
where value_field not in (
    'True','False'
)



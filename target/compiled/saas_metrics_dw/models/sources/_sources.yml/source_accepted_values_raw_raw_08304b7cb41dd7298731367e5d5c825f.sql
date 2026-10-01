
    
    

with all_values as (

    select
        ended_reason as value_field,
        count(*) as n_records

    from (select * from "saas_dw"."raw"."raw_subscriptions" where ended_reason is not null) dbt_subquery
    group by ended_reason

)

select *
from all_values
where value_field not in (
    'upgraded','downgraded','churned'
)



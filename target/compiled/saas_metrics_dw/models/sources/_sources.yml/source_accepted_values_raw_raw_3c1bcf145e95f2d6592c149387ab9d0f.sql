
    
    

with all_values as (

    select
        role as value_field,
        count(*) as n_records

    from "saas_dw"."raw"."raw_users"
    group by role

)

select *
from all_values
where value_field not in (
    'admin','member','analyst','viewer'
)



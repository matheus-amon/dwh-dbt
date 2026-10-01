
    
    

with all_values as (

    select
        is_admin as value_field,
        count(*) as n_records

    from "saas_dw"."staging"."stg_users"
    group by is_admin

)

select *
from all_values
where value_field not in (
    'True','False'
)




    
    

with all_values as (

    select
        status as value_field,
        count(*) as n_records

    from "saas_dw"."staging"."stg_accounts"
    group by status

)

select *
from all_values
where value_field not in (
    'active','churned'
)



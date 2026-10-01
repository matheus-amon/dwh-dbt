
    
    

with all_values as (

    select
        is_churned as value_field,
        count(*) as n_records

    from "saas_dw"."core"."dim_accounts"
    group by is_churned

)

select *
from all_values
where value_field not in (
    'True','False'
)



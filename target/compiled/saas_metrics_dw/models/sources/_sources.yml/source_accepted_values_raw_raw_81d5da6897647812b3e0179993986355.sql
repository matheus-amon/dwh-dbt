
    
    

with all_values as (

    select
        employee_band as value_field,
        count(*) as n_records

    from "saas_dw"."raw"."raw_accounts"
    group by employee_band

)

select *
from all_values
where value_field not in (
    '1-10','11-50','51-200','201-1000','1000+'
)



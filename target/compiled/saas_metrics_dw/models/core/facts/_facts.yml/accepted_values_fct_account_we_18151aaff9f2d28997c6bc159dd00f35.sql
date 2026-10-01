
    
    

with all_values as (

    select
        is_active_week as value_field,
        count(*) as n_records

    from "saas_dw"."core"."fct_account_weekly_usage"
    group by is_active_week

)

select *
from all_values
where value_field not in (
    'True','False'
)



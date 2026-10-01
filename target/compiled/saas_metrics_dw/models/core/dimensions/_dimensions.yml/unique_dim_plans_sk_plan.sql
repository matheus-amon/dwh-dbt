
    
    

select
    sk_plan as unique_field,
    count(*) as n_records

from "saas_dw"."core"."dim_plans"
where sk_plan is not null
group by sk_plan
having count(*) > 1



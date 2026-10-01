
    
    

select
    plan_code as unique_field,
    count(*) as n_records

from "saas_dw"."staging"."stg_plans"
where plan_code is not null
group by plan_code
having count(*) > 1



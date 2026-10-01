
    
    

select
    sk_date as unique_field,
    count(*) as n_records

from "saas_dw"."core"."dim_date"
where sk_date is not null
group by sk_date
having count(*) > 1



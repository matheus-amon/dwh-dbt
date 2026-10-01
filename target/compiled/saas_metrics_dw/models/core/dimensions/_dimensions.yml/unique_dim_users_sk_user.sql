
    
    

select
    sk_user as unique_field,
    count(*) as n_records

from "saas_dw"."core"."dim_users"
where sk_user is not null
group by sk_user
having count(*) > 1



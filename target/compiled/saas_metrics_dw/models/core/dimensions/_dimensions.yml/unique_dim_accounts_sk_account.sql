
    
    

select
    sk_account as unique_field,
    count(*) as n_records

from "saas_dw"."core"."dim_accounts"
where sk_account is not null
group by sk_account
having count(*) > 1



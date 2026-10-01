
    
    

select
    sk_account_week as unique_field,
    count(*) as n_records

from "saas_dw"."core"."fct_account_weekly_usage"
where sk_account_week is not null
group by sk_account_week
having count(*) > 1



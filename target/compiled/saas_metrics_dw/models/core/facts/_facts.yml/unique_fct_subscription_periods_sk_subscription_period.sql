
    
    

select
    sk_subscription_period as unique_field,
    count(*) as n_records

from "saas_dw"."core"."fct_subscription_periods"
where sk_subscription_period is not null
group by sk_subscription_period
having count(*) > 1



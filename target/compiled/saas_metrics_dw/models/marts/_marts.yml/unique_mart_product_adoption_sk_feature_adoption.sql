
    
    

select
    sk_feature_adoption as unique_field,
    count(*) as n_records

from "saas_dw"."marts"."mart_product_adoption"
where sk_feature_adoption is not null
group by sk_feature_adoption
having count(*) > 1



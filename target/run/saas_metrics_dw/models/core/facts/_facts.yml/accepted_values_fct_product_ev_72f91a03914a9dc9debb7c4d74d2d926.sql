
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_product_ev_72f91a03914a9dc9debb7c4d74d2d926"
    
      
    ) dbt_internal_test
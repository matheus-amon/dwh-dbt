
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_subscription_540fd9a5d1a2851c57089e63cb48c167"
    
      
    ) dbt_internal_test
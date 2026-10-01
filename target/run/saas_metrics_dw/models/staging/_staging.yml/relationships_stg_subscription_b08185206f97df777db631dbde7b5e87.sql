
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_stg_subscription_b08185206f97df777db631dbde7b5e87"
    
      
    ) dbt_internal_test
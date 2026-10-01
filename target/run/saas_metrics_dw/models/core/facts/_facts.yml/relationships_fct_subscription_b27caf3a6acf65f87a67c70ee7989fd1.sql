
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_subscription_b27caf3a6acf65f87a67c70ee7989fd1"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_subscription_9f98957be545b2969eb9ca26e7d52f8f"
    
      
    ) dbt_internal_test
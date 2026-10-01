
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_subscription_bcd36c65930daacdd30ae850254f8cb7"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."expect_non_negative_fct_product_events_days_since_spine_start"
    
      
    ) dbt_internal_test
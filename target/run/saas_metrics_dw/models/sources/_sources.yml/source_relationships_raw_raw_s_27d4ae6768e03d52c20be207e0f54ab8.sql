
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_relationships_raw_raw_s_27d4ae6768e03d52c20be207e0f54ab8"
    
      
    ) dbt_internal_test
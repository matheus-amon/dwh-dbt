
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_accepted_values_raw_raw_e8762d1b7f14f7225009f9e190a06b1d"
    
      
    ) dbt_internal_test
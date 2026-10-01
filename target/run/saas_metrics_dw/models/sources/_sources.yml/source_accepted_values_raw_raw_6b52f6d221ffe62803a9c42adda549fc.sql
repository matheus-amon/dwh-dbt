
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_accepted_values_raw_raw_6b52f6d221ffe62803a9c42adda549fc"
    
      
    ) dbt_internal_test
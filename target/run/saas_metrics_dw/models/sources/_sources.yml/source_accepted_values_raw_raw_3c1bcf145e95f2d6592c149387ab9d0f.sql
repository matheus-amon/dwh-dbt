
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_accepted_values_raw_raw_3c1bcf145e95f2d6592c149387ab9d0f"
    
      
    ) dbt_internal_test
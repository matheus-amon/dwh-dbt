
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_accepted_values_raw_raw_6ea0f47075a6ee7c0a5615626eada954"
    
      
    ) dbt_internal_test
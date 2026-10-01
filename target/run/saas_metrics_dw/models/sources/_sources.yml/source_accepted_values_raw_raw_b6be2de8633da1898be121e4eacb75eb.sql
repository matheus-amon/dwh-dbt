
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_accepted_values_raw_raw_b6be2de8633da1898be121e4eacb75eb"
    
      
    ) dbt_internal_test
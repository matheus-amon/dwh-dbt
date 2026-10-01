
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_source_accepted_rang_ce44c3c7a469ce344008efd865ef85f9"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_source_accepted_rang_61b78e7495b9bc4256b26ae8e78d7007"
    
      
    ) dbt_internal_test
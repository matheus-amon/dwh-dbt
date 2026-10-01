
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_accepted_range_mart__83e3eb5a13c1a2fd8c62488230827b86"
    
      
    ) dbt_internal_test
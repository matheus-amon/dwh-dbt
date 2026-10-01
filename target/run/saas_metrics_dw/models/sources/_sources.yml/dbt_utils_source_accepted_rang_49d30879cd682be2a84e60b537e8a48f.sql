
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_source_accepted_rang_49d30879cd682be2a84e60b537e8a48f"
    
      
    ) dbt_internal_test
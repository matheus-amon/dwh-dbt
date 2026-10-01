
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_relationships_raw_raw_s_651b4436efa4017f29b765805da0e036"
    
      
    ) dbt_internal_test
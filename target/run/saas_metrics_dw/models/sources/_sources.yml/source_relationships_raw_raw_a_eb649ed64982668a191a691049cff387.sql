
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_relationships_raw_raw_a_eb649ed64982668a191a691049cff387"
    
      
    ) dbt_internal_test
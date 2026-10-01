
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_relationships_raw_raw_p_f25541c82376f366b7063e7c90fd25b2"
    
      
    ) dbt_internal_test
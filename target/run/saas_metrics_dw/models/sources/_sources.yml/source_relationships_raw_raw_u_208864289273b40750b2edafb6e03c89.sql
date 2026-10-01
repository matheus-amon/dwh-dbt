
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_relationships_raw_raw_u_208864289273b40750b2edafb6e03c89"
    
      
    ) dbt_internal_test
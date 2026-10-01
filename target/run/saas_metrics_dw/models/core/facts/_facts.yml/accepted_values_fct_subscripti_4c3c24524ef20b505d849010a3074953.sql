
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_subscripti_4c3c24524ef20b505d849010a3074953"
    
      
    ) dbt_internal_test
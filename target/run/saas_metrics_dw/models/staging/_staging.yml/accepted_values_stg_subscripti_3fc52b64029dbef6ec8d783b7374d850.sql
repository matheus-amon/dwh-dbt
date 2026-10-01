
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_stg_subscripti_3fc52b64029dbef6ec8d783b7374d850"
    
      
    ) dbt_internal_test
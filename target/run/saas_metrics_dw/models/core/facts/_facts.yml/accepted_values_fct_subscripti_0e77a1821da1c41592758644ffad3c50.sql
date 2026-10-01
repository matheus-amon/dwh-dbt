
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_subscripti_0e77a1821da1c41592758644ffad3c50"
    
      
    ) dbt_internal_test
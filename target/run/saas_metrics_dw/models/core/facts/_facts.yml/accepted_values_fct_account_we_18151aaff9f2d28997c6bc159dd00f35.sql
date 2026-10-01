
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_account_we_18151aaff9f2d28997c6bc159dd00f35"
    
      
    ) dbt_internal_test
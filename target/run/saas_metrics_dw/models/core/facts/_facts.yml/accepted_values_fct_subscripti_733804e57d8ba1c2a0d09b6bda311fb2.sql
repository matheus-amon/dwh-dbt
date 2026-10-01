
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_subscripti_733804e57d8ba1c2a0d09b6bda311fb2"
    
      
    ) dbt_internal_test
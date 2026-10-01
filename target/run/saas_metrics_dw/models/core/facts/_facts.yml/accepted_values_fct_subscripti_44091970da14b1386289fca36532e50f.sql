
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_subscripti_44091970da14b1386289fca36532e50f"
    
      
    ) dbt_internal_test
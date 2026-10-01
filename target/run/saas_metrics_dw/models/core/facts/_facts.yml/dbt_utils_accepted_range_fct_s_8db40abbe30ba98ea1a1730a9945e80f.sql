
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_accepted_range_fct_s_8db40abbe30ba98ea1a1730a9945e80f"
    
      
    ) dbt_internal_test
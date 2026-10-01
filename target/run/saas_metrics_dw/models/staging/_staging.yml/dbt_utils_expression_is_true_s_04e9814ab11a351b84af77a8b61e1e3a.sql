
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_expression_is_true_s_04e9814ab11a351b84af77a8b61e1e3a"
    
      
    ) dbt_internal_test
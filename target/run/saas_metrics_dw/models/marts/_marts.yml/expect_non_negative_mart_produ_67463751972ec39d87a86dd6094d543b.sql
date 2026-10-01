
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."expect_non_negative_mart_produ_67463751972ec39d87a86dd6094d543b"
    
      
    ) dbt_internal_test
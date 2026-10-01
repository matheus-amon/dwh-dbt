
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."unique_fct_account_weekly_usage_sk_account_week"
    
      
    ) dbt_internal_test
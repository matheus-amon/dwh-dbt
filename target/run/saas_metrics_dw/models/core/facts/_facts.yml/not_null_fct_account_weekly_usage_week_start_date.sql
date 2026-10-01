
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."not_null_fct_account_weekly_usage_week_start_date"
    
      
    ) dbt_internal_test
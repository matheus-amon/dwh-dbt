
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."expect_non_negative_mart_cohort_retention_retained_accounts"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."source_expect_non_negative_raw_raw_subscriptions_mrr_usd"
    
      
    ) dbt_internal_test
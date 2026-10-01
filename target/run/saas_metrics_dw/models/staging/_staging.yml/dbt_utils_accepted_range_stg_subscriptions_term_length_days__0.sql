
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_accepted_range_stg_subscriptions_term_length_days__0"
    
      
    ) dbt_internal_test
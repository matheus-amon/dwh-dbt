
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_subscription_20f18e785f8674ee0ab38120034f0123"
    
      
    ) dbt_internal_test
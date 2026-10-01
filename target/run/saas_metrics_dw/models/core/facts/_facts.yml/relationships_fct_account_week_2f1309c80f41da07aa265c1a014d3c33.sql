
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_account_week_2f1309c80f41da07aa265c1a014d3c33"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_stg_subscription_6e9d3abc66a6b36ca6ad681e0322c45f"
    
      
    ) dbt_internal_test
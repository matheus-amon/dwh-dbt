
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."not_null_stg_product_events_event_week_start"
    
      
    ) dbt_internal_test
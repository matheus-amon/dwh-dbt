
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_accepted_range_dim_date_iso_day_of_week__True__7__1"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_stg_product_ev_1d50cfeafdf3b9e38f609f87a1c8bffa"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_mart_product_a_0a41ea1cf41cbc5f8ecc1c4ca0cec71b"
    
      
    ) dbt_internal_test
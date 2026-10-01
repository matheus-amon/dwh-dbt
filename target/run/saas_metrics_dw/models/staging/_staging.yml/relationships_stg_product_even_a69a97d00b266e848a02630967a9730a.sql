
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_stg_product_even_a69a97d00b266e848a02630967a9730a"
    
      
    ) dbt_internal_test
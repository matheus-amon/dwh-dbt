
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_mart_product_ado_746f3baf55af483000b05d98abd44833"
    
      
    ) dbt_internal_test
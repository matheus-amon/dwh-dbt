
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_product_even_24d5d40ad5995517b7a460f9238b944f"
    
      
    ) dbt_internal_test
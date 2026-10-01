
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_stg_product_even_0bd2f57cc7e711b737bdbbdb7ba80c08"
    
      
    ) dbt_internal_test
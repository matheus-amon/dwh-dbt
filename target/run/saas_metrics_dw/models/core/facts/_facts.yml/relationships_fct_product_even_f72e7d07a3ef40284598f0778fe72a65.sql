
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_product_even_f72e7d07a3ef40284598f0778fe72a65"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_product_even_f3ab9abbfa7545d1bed10e207beb86a7"
    
      
    ) dbt_internal_test
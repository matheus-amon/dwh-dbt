
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_stg_product_ev_457770b0e1cb56acc5257da56f43b69b"
    
      
    ) dbt_internal_test

    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_fct_product_ev_6da795e7fae12d366d703e794ba49c5e"
    
      
    ) dbt_internal_test
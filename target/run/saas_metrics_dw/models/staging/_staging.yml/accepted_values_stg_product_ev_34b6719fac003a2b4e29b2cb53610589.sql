
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."accepted_values_stg_product_ev_34b6719fac003a2b4e29b2cb53610589"
    
      
    ) dbt_internal_test
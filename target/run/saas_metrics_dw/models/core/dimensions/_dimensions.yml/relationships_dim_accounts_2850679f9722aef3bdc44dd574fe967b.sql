
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_dim_accounts_2850679f9722aef3bdc44dd574fe967b"
    
      
    ) dbt_internal_test
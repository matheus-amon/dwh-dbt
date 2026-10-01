
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_dim_users_8a0a971554d0c547ada5e81e836db7bb"
    
      
    ) dbt_internal_test
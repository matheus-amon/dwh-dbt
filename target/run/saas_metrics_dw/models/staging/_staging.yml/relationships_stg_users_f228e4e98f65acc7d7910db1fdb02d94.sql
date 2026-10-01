
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_stg_users_f228e4e98f65acc7d7910db1fdb02d94"
    
      
    ) dbt_internal_test
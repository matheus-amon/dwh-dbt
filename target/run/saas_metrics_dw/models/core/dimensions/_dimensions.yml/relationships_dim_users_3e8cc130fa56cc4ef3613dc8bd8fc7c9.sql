
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_dim_users_3e8cc130fa56cc4ef3613dc8bd8fc7c9"
    
      
    ) dbt_internal_test
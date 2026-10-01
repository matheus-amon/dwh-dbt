
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."relationships_fct_account_week_54326cc60e0093c0188ded8b1049ed20"
    
      
    ) dbt_internal_test
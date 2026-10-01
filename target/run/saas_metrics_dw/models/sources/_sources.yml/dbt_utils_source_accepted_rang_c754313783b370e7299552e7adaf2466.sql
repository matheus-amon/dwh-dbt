
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_source_accepted_rang_c754313783b370e7299552e7adaf2466"
    
      
    ) dbt_internal_test
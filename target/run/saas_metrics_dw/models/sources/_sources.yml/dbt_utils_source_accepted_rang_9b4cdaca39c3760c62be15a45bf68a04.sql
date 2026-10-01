
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "saas_dw"."dbt_test_failures"."dbt_utils_source_accepted_rang_9b4cdaca39c3760c62be15a45bf68a04"
    
      
    ) dbt_internal_test
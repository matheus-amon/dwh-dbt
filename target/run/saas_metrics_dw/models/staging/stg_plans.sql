
  create view "saas_dw"."staging"."stg_plans__dbt_tmp"
    
    
  as (
    with source as (

    select * from "saas_dw"."raw"."raw_plans"

),

renamed as (

    select
        cast(plan_code as varchar)            as plan_code,
        cast(plan_name as varchar)            as plan_name,
        cast(monthly_price_usd as numeric(10, 2)) as monthly_price_usd,
        cast(included_seats as integer)       as included_seats,
        cast(billing_interval as varchar)     as billing_interval,
        cast(tier_rank as integer)            as tier_rank

    from source

)

select * from renamed
  );
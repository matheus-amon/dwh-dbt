with plans as (

    select * from "saas_dw"."staging"."stg_plans"

),

final as (

    select
        md5(cast(coalesce(cast(plan_code as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as sk_plan,
        plan_code,
        plan_name,
        monthly_price_usd,
        included_seats,
        billing_interval,
        tier_rank

    from plans

)

select * from final
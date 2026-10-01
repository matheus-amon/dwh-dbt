with plans as (

    select * from {{ ref('stg_plans') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['plan_code']) }} as sk_plan,
        plan_code,
        plan_name,
        monthly_price_usd,
        included_seats,
        billing_interval,
        tier_rank

    from plans

)

select * from final

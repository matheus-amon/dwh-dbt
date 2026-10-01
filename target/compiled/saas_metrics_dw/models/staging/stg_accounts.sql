with source as (

    select * from "saas_dw"."raw"."raw_accounts"

),

renamed as (

    select
        cast(account_id as integer)            as account_id,
        cast(account_name as varchar)          as account_name,
        cast(domain as varchar)               as domain,
        cast(industry as varchar)             as industry,
        cast(employee_band as varchar)        as employee_band,
        cast(country_code as varchar)         as country_code,
        cast(region as varchar)               as region,
        cast(signed_up_at as timestamp)       as signed_up_at,
        cast(signed_up_at as date)            as signed_up_date,
        -- The cohort anchor the retention mart groups by. Derived once here so every
        -- downstream model anchors cohorts the same way.
        date_trunc('month', signed_up_at)::date as signup_month,
        cast(plan_code_at_signup as varchar)  as plan_code_at_signup,
        cast(seats as integer)                as seats,
        cast(status as varchar)               as status,
        cast(churned_at as timestamp)         as churned_at

    from source

),

derived as (

    select
        *,

        (status = 'churned')                  as is_churned,

        -- Days between signing up and churning. Null for accounts that never churned.
        case
            when churned_at is not null
            then (churned_at::date - signed_up_date)
        end                                    as days_to_churn,

        (churned_at is not null)              as has_churn_timestamp

    from renamed

)

select * from derived
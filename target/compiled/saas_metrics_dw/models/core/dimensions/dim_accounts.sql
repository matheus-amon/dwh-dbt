with accounts as (

    select * from "saas_dw"."staging"."stg_accounts"

),

final as (

    select
        -- Surrogate key for joins; account_id is kept alongside as the natural key so
        -- warehouse output can still be traced back to the source system.
        md5(cast(coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as sk_account,
        account_id,
        account_name,
        domain,
        industry,
        employee_band,
        country_code,
        region,
        plan_code_at_signup,
        seats,
        status,
        is_churned,
        signed_up_at,
        signed_up_date,
        signup_month,
        churned_at

    from accounts

)

select * from final
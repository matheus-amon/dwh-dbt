with users as (

    select * from {{ ref('stg_users') }}

),

joined as (

    select
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as sk_user,
        user_id,
        -- Foreign key onto the account dimension, so user-level facts never join the raw
        -- natural key on the way to a report.
        {{ dbt_utils.generate_surrogate_key(['account_id']) }} as fk_account,
        account_id,
        email,
        full_name,
        role,
        is_admin,
        created_at,
        last_seen_at,
        last_seen_date,
        joined_month

    from users

)

select * from joined

with source as (

    select * from "saas_dw"."raw"."raw_users"

),

renamed as (

    select
        cast(user_id as integer)            as user_id,
        cast(account_id as integer)         as account_id,
        cast(email as varchar)              as email,
        cast(full_name as varchar)          as full_name,
        cast(role as varchar)               as role,
        cast(is_admin as boolean)           as is_admin,
        cast(created_at as timestamp)       as created_at,
        cast(last_seen_at as timestamp)     as last_seen_at,
        cast(last_seen_at as date)          as last_seen_date,
        date_trunc('month', created_at)::date as joined_month

    from source

)

select * from renamed
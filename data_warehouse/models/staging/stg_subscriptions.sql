with source as (

    select * from {{ source('raw', 'raw_subscriptions') }}

),

renamed as (

    select
        cast(subscription_id as bigint)        as subscription_id,
        cast(account_id as integer)            as account_id,
        cast(plan_code as varchar)             as plan_code,
        cast(billing_interval as varchar)      as billing_interval,
        cast(seats as integer)                 as seats,
        cast(discount_pct as numeric(5, 2))    as discount_pct,
        cast(mrr_usd as numeric(12, 2))        as mrr_usd,
        cast(started_at as timestamp)          as term_start_at,
        cast(ended_at as timestamp)            as term_end_at,
        cast(ended_reason as varchar)          as ended_reason

    from source

),

derived as (

    select
        *,

        date_trunc('month', term_start_at)::date   as term_start_month,
        cast(term_start_at as date)                 as term_start_date,
        cast(term_end_at as date)                   as term_end_date,

        -- A term with no end is the account's current state.
        (term_end_at is null)                       as is_current_term,
        (term_end_at is not null)                   as is_closed_term,

        (ended_reason = 'upgraded')                 as is_upgrade,
        (ended_reason = 'downgraded')               as is_downgrade,
        (ended_reason = 'churned')                  as is_churn,

        -- Length of the term in whole days, inclusive of the start date. Null while current,
        -- because the term has no end yet.
        case
            when term_end_at is not null
            then (term_end_at::date - term_start_at::date)
        end                                         as term_length_days,

        (discount_pct > 0)                         as is_discounted

    from renamed

)

select * from derived

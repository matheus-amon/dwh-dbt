{#
    Weekly product usage per account.

    This is where the decline-before-churn behaviour the generator models becomes visible to
    the warehouse: `events_last_4_weeks` here is what `mart_account_health` ranks accounts on.
    The grain is one row per account per week with at least one event, so a week with no
    activity is an absence rather than a zero row — the health mart treats the two differently.
#}

with events as (

    select * from {{ ref('fct_product_events') }}

),

weekly as (

    select
        account_id,
        week_start_date,

        count(*)                                            as event_count,
        count(distinct session_id)                          as session_count,
        count(distinct user_id)                             as active_user_count,
        count(distinct feature)                             as distinct_feature_count,
        count(distinct feature) filter (where is_gated_feature) as gated_feature_count,
        count(*) filter (where is_api_event)                as api_event_count,

        min(event_ts)                                       as first_event_at,
        max(event_ts)                                       as last_event_at

    from events
    group by account_id, week_start_date

),

with_calendar as (

    select
        weekly.*,
        {{ dbt_utils.generate_surrogate_key(['weekly.account_id']) }}  as fk_account,
        {{ dbt_utils.generate_surrogate_key(['weekly.week_start_date']) }} as fk_date,

        dim_date.day_of_week,
        dim_date.week_of_year,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        date_trunc('month', weekly.week_start_date)::date as month_start_date

    from weekly
    inner join {{ ref('dim_date') }}
        on dim_date.date_day = weekly.week_start_date

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['account_id', 'week_start_date']) }}
                                                            as sk_account_week,
        fk_account,
        account_id,
        fk_date,
        week_start_date,
        week_of_year,
        month_start_date,
        month_year,
        year_number,
        quarter_number,

        event_count,
        session_count,
        active_user_count,
        distinct_feature_count,
        gated_feature_count,
        api_event_count,
        first_event_at,
        last_event_at,

        -- Engagement per head, which normalises away the fact that a 5000-seat account
        -- generates more raw events than a 10-seat one.
        {{ safe_divide('event_count', 'active_user_count') }}          as events_per_active_user,
        {{ safe_divide('event_count', 'session_count') }}              as events_per_session,
        {{ safe_divide('api_event_count', 'event_count') }}           as api_event_share,

        -- Sessions and events both present means the account was genuinely used, not
        -- just pinged once.
        (session_count > 0 and event_count > 0)                        as is_active_week

    from with_calendar

)

select * from final

{#
    Product telemetry at event grain, incrementally built.

    Materialisation, incremental strategy and unique key are configured in dbt_project.yml so
    there is one place that decides how this model is built.

    The incremental filter is a lookback from the high-water mark rather than a strict
    `> max(event_ts)`. Event ids increase with time and the merge is keyed on event_id, so
    re-reading a day is idempotent — which matters because a real pipeline will emit events
    whose event_ts is slightly older than the last one it wrote.

    Operational caveat, learned the hard way: a merge only inserts and updates, it never
    deletes. If the source is reseeded or truncated — regenerating the synthetic dataset, for
    instance — rows in this table whose events no longer exist upstream survive as orphans and
    quietly distort anything built on top. Re-run with --full-refresh whenever the source is
    rebuilt rather than appended to.
#}

with source as (

    select * from {{ ref('stg_product_events') }}

),

scoped as (

    select * from source

    {% if is_incremental() %}
    where event_ts >= (
        select coalesce(max(event_ts), timestamp '1900-01-01') - interval '1 day'
        from {{ this }}
    )
    {% endif %}

),

joined as (

    select
        scoped.event_id,
        scoped.account_id,
        scoped.user_id,

        {{ dbt_utils.generate_surrogate_key(['scoped.account_id']) }} as fk_account,
        {{ dbt_utils.generate_surrogate_key(['scoped.user_id']) }}    as fk_user,
        {{ dbt_utils.generate_surrogate_key(['scoped.event_date']) }} as fk_date,

        scoped.event_ts,
        scoped.event_date,
        dim_date.day_of_week,
        dim_date.day_name,
        dim_date.is_weekend,
        dim_date.week_start_date,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        scoped.event_week_start,
        scoped.days_since_spine_start,

        scoped.event_name,
        scoped.feature,
        scoped.is_gated_feature,
        scoped.platform,
        scoped.is_api_event,
        scoped.session_id,
        scoped.country_code

    from scoped
    inner join {{ ref('dim_date') }}
        on dim_date.date_day = scoped.event_date

)

select * from joined

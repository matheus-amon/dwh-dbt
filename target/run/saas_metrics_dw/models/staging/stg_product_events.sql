
  create view "saas_dw"."staging"."stg_product_events__dbt_tmp"
    
    
  as (
    with source as (

    select * from "saas_dw"."raw"."raw_product_events"

),

renamed as (

    select
        cast(event_id as bigint)            as event_id,
        cast(account_id as integer)         as account_id,
        cast(user_id as integer)            as user_id,
        cast(event_name as varchar)         as event_name,
        cast(feature as varchar)            as feature,
        cast(platform as varchar)           as platform,
        cast(session_id as varchar)         as session_id,
        cast(country_code as varchar)       as country_code,
        cast(event_ts as timestamp)         as event_ts,
        cast(event_date as date)            as event_date

    from source

),

derived as (

    select
        *,

        -- Week starting Sunday, aligned to the weekly usage fact's grain.
        date_trunc('week', event_ts)::date   as event_week_start,

        (platform = 'api')                  as is_api_event,

        -- `core` and `core_dashboard` are available on every plan; the rest are gated by
        -- tier. Adoption metrics use this to separate reach from entitlement.
        (feature not in ('core', 'core_dashboard')) as is_gated_feature,

        -- Days since the start of the date spine, used as a monotonic ordering key by the
        -- incremental fact. The var is quoted: an unquoted 2023-01-01 is arithmetic in YAML.
        (event_date - '2023-01-01'::date) as days_since_spine_start

    from renamed

)

select * from derived
  );
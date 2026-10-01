

with source as (

    select * from "saas_dw"."staging"."stg_product_events"

),

scoped as (

    select * from source

    
    where event_ts >= (
        select coalesce(max(event_ts), timestamp '1900-01-01') - interval '1 day'
        from "saas_dw"."core"."fct_product_events"
    )
    

),

joined as (

    select
        scoped.event_id,
        scoped.account_id,
        scoped.user_id,

        md5(cast(coalesce(cast(scoped.account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_account,
        md5(cast(coalesce(cast(scoped.user_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))    as fk_user,
        md5(cast(coalesce(cast(scoped.event_date as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_date,

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
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = scoped.event_date

)

select * from joined

  
    

  create  table "saas_dw"."core"."dim_date__dbt_tmp"
  
  
    as
  
  (
    -- The spine reaches to the build date rather than to the last day in the data, so a month
-- with no activity still produces a row. A revenue mart that silently omits empty months
-- hides the gap instead of reporting it.
with spine as (

    

with days as (

    select generate_series(
        cast('2023-01-01' as date),
        cast(current_timestamp as date),
        interval '1 day'
    )::date as date_day

),

calendar as (

    select
        date_day,
        extract(isodow from date_day)::integer          as iso_day_of_week,
        extract(dow from date_day)::integer            as day_of_week,
        to_char(date_day, 'FMDay')                     as day_name,
        extract(day from date_day)::integer            as day_of_month,
        extract(doy from date_day)::integer            as day_of_year,
        extract(week from date_day)::integer           as week_of_year,
        extract(month from date_day)::integer          as month_number,
        to_char(date_day, 'FMMonth')                   as month_name,
        extract(quarter from date_day)::integer        as quarter_number,
        extract(year from date_day)::integer           as year_number

    from days

)

select
    md5(cast(coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))        as sk_date,
    date_day,
    iso_day_of_week,
    day_of_week,
    day_name,
    day_of_month,
    day_of_year,
    week_of_year,
    month_number,
    month_name,
    quarter_number,
    year_number,

    date_trunc('week', date_day)::date                          as week_start_date,
    (date_trunc('week', date_day) + interval '6 days')::date    as week_end_date,
    date_trunc('month', date_day)::date                         as month_start_date,
    (date_trunc('month', date_day) + interval '1 month - 1 day')::date as month_end_date,
    date_trunc('quarter', date_day)::date                      as quarter_start_date,
    (date_trunc('quarter', date_day) + interval '3 months - 1 day')::date as quarter_end_date,
    date_trunc('year', date_day)::date                          as year_start_date,
    (date_trunc('year', date_day) + interval '1 year - 1 day')::date  as year_end_date,

    -- Sortable 'YYYY-MM' label, used as a grain key by the time-series marts.
    to_char(date_day, 'YYYY-MM')                                as month_year,
    to_char(date_day, 'IYYY-"W"IW')                             as iso_year_week,

    -- Comparison anchors, so period-over-period logic does not have to do date arithmetic
    -- inline. Each is null where the prior period falls outside the spine.
    case when iso_day_of_week >= 6 then true else false end      as is_weekend,
    (date_day - interval '1 day')::date                          as prior_day_date,
    (date_trunc('week', date_day) - interval '1 week')::date    as prior_week_start_date,
    (date_trunc('month', date_day) - interval '1 month')::date   as prior_month_start_date,
    (date_day - interval '1 year')::date                        as prior_year_same_day

from calendar



)

select * from spine
  );
  
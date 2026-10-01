-- The spine reaches to the build date rather than to the last day in the data, so a month
-- with no activity still produces a row. A revenue mart that silently omits empty months
-- hides the gap instead of reporting it.
with spine as (

    {{ generate_date_spine("'" ~ var('date_spine_start_date') ~ "'", "current_timestamp") }}

)

select * from spine

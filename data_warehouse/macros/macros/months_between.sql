{#
    Whole months between two dates, ignoring the day of month.

    Used for cohort offsets, where "month 3 after signup" must mean the same thing for an
    account that signed up on the 2nd and one that signed up on the 28th.
#}
{% macro months_between(start_date, end_date) -%}
    (
        (extract(year from {{ end_date }}) - extract(year from {{ start_date }})) * 12
        + (extract(month from {{ end_date }}) - extract(month from {{ start_date }}))
    )::integer
{%- endmacro %}

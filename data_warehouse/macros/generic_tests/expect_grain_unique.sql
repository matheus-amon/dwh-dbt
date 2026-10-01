{% test expect_grain_unique(model, columns) %}

{#
    Uniqueness over a declared set of grain columns.

    Preferred over testing the surrogate key for uniqueness, because it asserts the grain the
    model documents rather than a hash derived from it. If a model's grain silently changes —
    an extra dimension added to the group by, or a filter dropped — the surrogate key changes
    with it and keeps passing, while this fails.

    Example:

        data_tests:
          - expect_grain_unique:
              arguments:
                columns: ["account_id", "month_start_date"]
#}

{%- set column_list = columns.split(', ') if columns is string else columns -%}

select
    {% for column in column_list -%}
        {{ column }}{% if not loop.last %}, {% endif %}
    {%- endfor %},
    count(*) as duplicate_grain_rows

from {{ model }}

group by
    {% for column in column_list -%}
        {{ loop.index }}{% if not loop.last %}, {% endif %}
    {%- endfor %}

having count(*) > 1

{% endtest %}

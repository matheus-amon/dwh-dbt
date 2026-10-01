{#
    Division that returns NULL instead of raising on a zero denominator.

    Deliberately not coalesced to 0: "no revenue divided by no customers" is unknown, not
    zero, and a mart that reports it as 0 reads as "this segment produced nothing" when it
    actually never existed. Where a zero is the right answer, coalesce explicitly in the
    model so the decision is visible.
#}
{% macro safe_divide(numerator, denominator) -%}
    cast({{ numerator }} as numeric)
        / nullif(cast({{ denominator }} as numeric), 0)
{%- endmacro %}

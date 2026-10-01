{% test expect_non_negative(model, column_name) %}

{# Fails when a measure goes negative. Applied to money and counts, where a negative value
   is always a modelling bug rather than a legitimate credit or refund. #}

select {{ column_name }}
from {{ model }}
where {{ column_name }} < 0

{% endtest %}

{#
    Keep dbt's custom schema names verbatim.

    By default dbt concatenates the custom schema with the target schema, so `+schema: marts`
    against a target of `public` produces `public_marts`. That is a reasonable default but it
    means the schema a model lands in depends on what the profile is called, which breaks the
    asset URIs the Airflow DAGs reference. Overriding this makes `marts` mean `marts`.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

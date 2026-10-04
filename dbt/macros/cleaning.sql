{# The source writes missing values as '?'. Turn '?' and empty text into NULL. #}
{% macro clean_text(column) -%}
    nullif(nullif(trim({{ column }}), '?'), '')
{%- endmacro %}

{# The source uses day/month/year with or without leading zeros, e.g. 29/2/2016 01:16. #}
{% macro parse_ts(column) -%}
    to_timestamp(nullif(trim({{ column }}), '?'), 'DD/MM/YYYY HH24:MI')::timestamp
{%- endmacro %}

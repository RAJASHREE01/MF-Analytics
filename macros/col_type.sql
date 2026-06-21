{% macro print_model_columns(model_name) %}

    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {% for col in columns %}
         {{ log(col.name ~ " : " ~ col.dtype, info=True) }}
    {% endfor %}

{% endmacro %}
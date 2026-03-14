{% macro pivot_status_counts(source_col, statuses) %}
    {% for status in statuses %}
        count(case when {{ source_col }} = '{{ status }}' then 1 end) as {{ status | replace(' ','_') | replace('&','and') }}_orders
        {% if not loop.last %},{% endif %}
    {% endfor %}
  
{% endmacro %}
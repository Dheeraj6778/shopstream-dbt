{% set categories_query %}
    select distinct category
    from {{ ref('stg_products') }}
    order by 1
{% endset %}

{% if execute %}
    {% set results = run_query(categories_query) %}
    {% set categories = results.columns[0].values() %}
{% else %}
    {% set categories = [] %}
{% endif %}

select
    order_item_date
    {% for cat in categories %}
        , round(sum(case when category = '{{ cat }}' then line_total else 0 end),2)
          as {{ cat | lower | replace(' ', '_') | replace('&', 'and') }}_revenue
    {% endfor %}
from {{ ref('int_order_items_enriched') }}
group by order_item_date
order by 1
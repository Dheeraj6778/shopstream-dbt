{{
  config(
    materialized = 'incremental',
    unique_key = 'order_id',
    incremental_strategy = 'merge',
    liquid_clustered_by=['order_date','customer_id'],
    post_hook = "ANALYZE TABLE {{ this }} COMPUTE STATISTICS"
  )
}}



with orders as (
    select *
    from {{ ref('stg_orders') }}
    {% if is_incremental() %}
      where order_updated_at >= (
            select max(order_updated_at) - interval '1 day'
            from {{ this }}
      )
    {% endif %}
),
customers as (
    select *
    from {{ ref('snap_customers') }}
),
order_stats as (
    select order_id,
        count(*) as item_count,
        sum(quantity) as total_units,
        sum(line_total) as order_amount
    from {{ ref('int_order_items_enriched') }}
    group by order_id
),
dim_date as (
    select *
    from {{ ref('dim_date') }}
),
final as (
  select o.order_id,
        o.order_status,
        o.currency_code,
        o.order_amount as order_amount_from_orders,
        o.discount_amount,
        o.total_amount,
        o.order_placed_at,
        o.order_updated_at,
        o.order_date,
        os.item_count,
        os.total_units,
        os.order_amount,
        c.*,
        d.*
  from orders o
  left join customers c on o.customer_id = c.customer_id
  left join order_stats os on o.order_id = os.order_id
  left join dim_date d on o.order_date = d.date_day
)
select *
from final


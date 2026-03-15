{{
  config(
    materialized = 'incremental',
    unique_key = 'order_id',
    incremental_strategy = 'merge',
    merge_update_columns = [
        'order_status',
        'total_amount',
        'order_updated_at'
    ],
    partition_by = {"field": "order_date","data_type":"date"}
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
)
select order_id,
        customer_id,
        order_status,
        currency_code,
        order_amount,
        discount_amount,
        total_amount,
        order_placed_at,
        order_updated_at,
        order_date
from orders


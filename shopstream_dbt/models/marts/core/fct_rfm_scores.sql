
{{
  config(
    materialized = 'table',
    tags = ['weekly']
    )
}}


with orders as (
    select *
    from {{ ref('fct_orders') }}
    where order_status='delivered'
),
rfm as (
    select customer_id,
        datediff(current_date(), max(order_date)) as recency,
        count(distinct order_id) as frequency,
        round(sum(total_amount),2) as monetary_value
    from orders
    group by customer_id
)
select * from rfm
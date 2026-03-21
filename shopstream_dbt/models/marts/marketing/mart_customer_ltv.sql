
{{
  config(
    materialized = 'table',
        tags = ['weekly','marketing']
    )
}}


with orders as (
    select *
    from {{ ref('fct_orders') }}
    where order_status='delivered'
),
ltv as (
    select customer_id,
            count(order_id) as total_orders,
            round(sum(total_amount),2) as total_revenue,
            round(avg(total_amount),2) as avg_order_value,
            min(order_date) as first_order_date,
            max(order_date) as last_order_date,
            datediff(current_date(), min(order_date)) as days_since_first_order,
            datediff(max(order_date), min(order_date)) as customer_age_days,
            datediff(current_date(), max(order_date)) as days_since_last_order
    from orders
    group by customer_id
),
segments as (
    select *,
        case 
            when total_orders>=10 and total_revenue>=5000 then 'VIP'
            when total_orders>=3 then 'Medium Value'
            when total_orders=1 then 'New Customer'
            when days_since_last_order>=180 then 'Churned'
            else 'Low Value'
        end as customer_segment
    from ltv
)
select s.*,
        c.country,
        c.signup_channel
from segments s
left join {{ ref('snap_customers') }} c using (customer_id)


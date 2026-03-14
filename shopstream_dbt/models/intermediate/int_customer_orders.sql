with orders as (
    select *
    from {{ ref('stg_orders') }}
),
customers as (
    select *
    from {{ ref('stg_customers') }}
),
enriched as (
    select o.*,
        c.first_name,
        c.last_name,
        c.city,
        c.country,
        c.signup_channel,
        c.customer_updated_at,
        c.customer_signup_date
    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)
select *
from enriched
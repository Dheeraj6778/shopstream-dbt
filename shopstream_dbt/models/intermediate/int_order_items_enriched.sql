


with order_items as (
    select *
    from {{ ref('stg_order_items') }}
),
products as (
    select *
    from {{ ref('stg_products') }}
),
enriched as (
    select oi.*,
        p.product_name,
        p.category,
        p.vendor_id,
        oi.quantity * oi.unit_price as line_total

    from order_items oi
    left join products p
        on oi.product_id = p.product_id
)
select *
from enriched
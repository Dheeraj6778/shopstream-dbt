

select count(*)
from {{ source('shopstream_raw', 'orders') }}
where amount is null

select *
from {{ source('shopstream_raw', 'customers') }}

select *
from {{ source('shopstream_raw', 'order_items') }}

select count(*)
from {{ source('shopstream_raw', 'products') }}
where name is null

select count(*)
from {{ source('shopstream_raw', 'events') }}
where event_type is null

select {{cents_to_dollas(120)}} as amount_in_dollars

select order_date,
        {{pivot_status_counts('order_status', ['placed','cancelled','delivered','shipped'])}},
        count(*) as total_orders
from {{ ref('stg_orders') }}
group by order_date
order by order_date

select distinct country
from {{ ref('stg_customers') }}

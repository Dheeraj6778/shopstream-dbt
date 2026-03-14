

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
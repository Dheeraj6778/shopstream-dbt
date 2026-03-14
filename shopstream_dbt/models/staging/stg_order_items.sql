
with source as (
    select *
    from {{ source('shopstream_raw', 'order_items') }}

),
renamed as (
    select order_item_id,
            order_id,
            product_id,
            quantity,
            coalesce(unit_price, 0) as unit_price,  
            created_at as order_item_created_at,
            date(created_at) as order_item_date
    from source
    where order_item_id is not null
)
select *
from renamed
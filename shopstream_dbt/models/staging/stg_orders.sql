
with source as (
    select *
    from {{ source('shopstream_raw', 'orders') }}
),
renamed as (
    select order_id,
            customer_id,
            lower(trim(status)) as order_status,
            upper(trim(currency)) as currency_code,
            coalesce(amount, 0) as order_amount,
            coalesce(discount,0) as discount_amount,
            round(amount - coalesce(discount,0),2) as total_amount,
            created_at as order_placed_at,
            updated_at as order_updated_at,
            date(created_at) as order_date
    from source
    where order_id is not null
)
select *
from renamed
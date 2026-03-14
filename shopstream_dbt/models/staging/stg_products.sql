

with source as (
    select *
    from {{ source('shopstream_raw', 'products') }}
),
renamed as (
    select product_id,
            vendor_id,
            lower(trim(name)) as product_name,
            lower(trim(category)) as category,
            coalesce(price, 0) as price,
            boolean(coalesce(is_active, false)) as is_active,
            created_at as product_created_at,
            updated_at as product_updated_at,
            date(created_at) as product_created_date
    from source
    where product_id is not null
)
select *
from renamed
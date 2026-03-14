
with source as (
    select *
    from {{ source('shopstream_raw', 'customers') }}
),
renamed as (
    select customer_id,
            lower(trim(first_name)) as first_name,
            lower(trim(last_name)) as last_name,
            city,
            upper(country) as country,
            signup_channel,
            created_at as customer_created_at,
            updated_at as customer_updated_at,
            date(created_at) as customer_signup_date
    from source
    where customer_id is not null
)
select *
from renamed
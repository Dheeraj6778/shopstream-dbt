
with source as (
    select *
    from {{ source('shopstream_raw', 'events') }}
),
renamed as (
    select event_id,
            customer_id,
            session_id,
            lower(trim(event_type)) as event_type,
            page_url,
            from_json(
                event_payload,
                'order_id bigint, product_id bigint, query string'
            ) as event_payload,
            event_date,
            event_at as event_timestamp
    from source
    where event_id is not null
)
select event_id,
        customer_id,
        session_id,
        event_type,
        page_url,
        event_payload.order_id as order_id,
        event_payload.product_id as product_id,
        event_payload.query as search_query,
        event_date,
        event_timestamp
from renamed

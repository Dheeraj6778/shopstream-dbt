
with events as (
    select *
    from {{ ref('stg_events') }}
),
enriched as (
    select session_id,
        customer_id,
        event_date,
        min(event_timestamp) as session_start_at,
        max(event_timestamp) as session_end_at,
        datediff(second, min(event_timestamp), max(event_timestamp)) as session_duration_seconds,
        count(case when event_type='page_view' then 1 end) as page_views,
        count(case when event_type='add_to_cart' then 1 end) as add_to_carts,
        count(case when event_type='purchase' then 1 end) as purchases,
        count(case when event_type='search' then 1 end) as searches,
        count(case when event_type='checkout' then 1 end) as checkouts,
        count(distinct page_url) as unique_pages_viewed,
        max(case when event_type='purchase' then 1 end) as did_purchase,
        max(case when event_type='add_to_cart' then 1 end) as did_add_to_cart,
        count(*) as total_events
    from events
    group by session_id, customer_id, event_date
)
select *
from enriched


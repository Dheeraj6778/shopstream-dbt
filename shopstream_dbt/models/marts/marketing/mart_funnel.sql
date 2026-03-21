WITH customer_aggregated AS (
    -- aggregate int_customer_orders to customer level first
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(total_amount), 2)                 AS total_revenue,
        ROUND(AVG(total_amount), 2)                 AS avg_order_value,
        MIN(order_date)                             AS first_order_date,
        MAX(order_date)                             AS last_order_date
    FROM {{ ref('int_customer_orders') }}
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),

session_orders AS (
    SELECT
        s.*,
        o.total_orders,
        o.total_revenue,
        o.avg_order_value,
        o.first_order_date,
        o.last_order_date
    FROM {{ ref('int_session_events') }} s
    LEFT JOIN customer_aggregated o
        ON s.customer_id = o.customer_id
)

SELECT
    event_date,

    -- funnel step counts
    COUNT(DISTINCT session_id)                                                    AS total_sessions,
    SUM(CASE WHEN page_views   > 0 THEN 1 ELSE 0 END)                           AS sessions_with_page_view,
    SUM(CASE WHEN searches     > 0 THEN 1 ELSE 0 END)                           AS sessions_with_search,
    SUM(CASE WHEN add_to_carts > 0 THEN 1 ELSE 0 END)                           AS sessions_with_add_to_cart,
    SUM(CASE WHEN checkouts    > 0 THEN 1 ELSE 0 END)                           AS sessions_with_checkout,
    SUM(CASE WHEN purchases    > 0 THEN 1 ELSE 0 END)                           AS sessions_with_purchase,

    -- step-to-step conversion rates
    ROUND(100.0 * SUM(CASE WHEN add_to_carts > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(DISTINCT session_id), 0), 2)                              AS page_view_to_add_to_cart_rate,

    ROUND(100.0 * SUM(CASE WHEN checkouts > 0 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN add_to_carts > 0 THEN 1 ELSE 0 END), 0), 2)     AS add_to_cart_to_checkout_rate,

    ROUND(100.0 * SUM(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN checkouts > 0 THEN 1 ELSE 0 END), 0), 2)        AS checkout_to_purchase_rate,

    ROUND(100.0 * SUM(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(DISTINCT session_id), 0), 2)                              AS overall_conversion_rate,

    -- revenue from converted sessions
    ROUND(SUM(CASE WHEN did_purchase = 1 THEN total_revenue ELSE 0 END), 2)     AS revenue_from_converted_sessions,

    ROUND(SUM(CASE WHEN did_purchase = 1 THEN total_revenue ELSE 0 END)
        / NULLIF(SUM(CASE WHEN purchases > 0 THEN 1 ELSE 0 END), 0), 2)        AS avg_revenue_per_converted_session,

    -- customer quality of converting sessions
    ROUND(AVG(CASE WHEN did_purchase = 1 THEN avg_order_value END), 2)          AS avg_order_value_converted,
    ROUND(AVG(CASE WHEN did_purchase = 1 THEN total_orders END), 2)             AS avg_lifetime_orders_converted

FROM session_orders
GROUP BY event_date
ORDER BY event_date
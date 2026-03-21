

with base_cte as (
    select o.*,
        io.category

    from {{ ref('fct_orders') }} o
    left join {{ ref('int_order_items_enriched') }} io
        on o.order_id = io.order_id
),
grouped_data as (
    select order_date, 
            category, 
            country,
            count(distinct order_id) as total_orders,
            round(sum(total_amount),2) as total_revenue,
            round(avg(total_amount),2) as avg_order_value,
            count(distinct customer_id) as unique_customers,
            sum(total_units) as total_units_sold,
            round(sum(order_amount_from_orders),2) as gross_revenue,
            round(sum(discount_amount),2) as total_discounts,
            round(sum(order_amount_from_orders) - sum(discount_amount),2) as net_revenue,
            round(round(sum(order_amount_from_orders) - sum(discount_amount),2)/nullif(count(distinct order_id),0),2) as avg_net_revenue_per_order

    from base_cte
    group by order_date, category, country
)
select g.*,
        c.country_name,
        c.region,
        d.date_month,
        d.month_name,
        d.date_quarter,
        d.date_year,
        d.is_weekend,

        round(sum(g.net_revenue) over(order by g.order_date rows between unbounded preceding and current row
),2) as cumulative_net_revenue
from grouped_data g
left join {{ref('country_codes')}} c 
    on g.country = c.country_code
left join {{ ref('dim_date') }} d
    on g.order_date = d.date_day

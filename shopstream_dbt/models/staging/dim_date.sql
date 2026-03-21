{{
  config(
    materialized = 'table',
    )
}}

with date_spine as (
    select explode(
        sequence(
            to_date('2022-01-01'),
            current_date(),
            interval 1 day
        )
    ) as date_day
)

select date_day,
        year(date_day) as date_year,
        month(date_day) as date_month,
        day(date_day) as date_day_of_month,
        dayofweek(date_day) as day_of_week,
        dayofyear(date_day) as day_of_year,   
        quarter(date_day) as date_quarter,

        --names
        date_format(date_day, 'MMMM') as month_name,
        date_format(date_day, 'EEEE') as day_of_week_name,

        --flags
        case when dayofweek(date_day) in (1,7) then true else false end as is_weekend

from date_spine


{%test not_null_proportion(model,column_name, threshold=0.01) %}

    with validation as (
        select
            count(*) as total_rows,
            sum(case when {{ column_name }} is null then 1 else 0 end) as null_count
        from {{ model }}
    )
    select *
    from validation
    where null_count / total_rows > {{ threshold }}

{% endtest %}
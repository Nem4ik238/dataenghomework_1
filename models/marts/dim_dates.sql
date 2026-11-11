{{ config(distributed_replicated=true) }}

with bounds as (
    select
        min(order_date)                 as start_date,
        max(order_date)                 as end_date
    from {{ ref('stg_shop__orders') }}
    where not is_test_order
),

days as (
    select
        generate_series(start_date::timestamp, end_date::timestamp, interval '1 day')::date as date_day
    from bounds
)

select
    date_day,
    extract(year from date_day)::int            as year,
    extract(quarter from date_day)::int         as quarter,
    extract(month from date_day)::int           as month,
    to_char(date_day, 'FMMonth')                as month_name,
    to_char(date_day, 'YYYY-MM')                as year_month,
    extract(day from date_day)::int             as day_of_month,
    extract(isodow from date_day)::int          as day_of_week,
    to_char(date_day, 'FMDay')                  as day_of_week_name,
    extract(isodow from date_day) in (6, 7)     as is_weekend
from days

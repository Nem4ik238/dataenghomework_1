with source_confirmed as (
    select
        count(*)                        as orders_count,
        sum(total_amount)               as revenue
    from {{ source('shop', 'orders') }}
    where status = 'paid'
      and order_id in (
          select order_id
          from {{ source('shop', 'payments') }}
          where payment_status = 'success'
            and amount > 0
      )
),

mart_confirmed as (
    select
        count(*)                        as orders_count,
        sum(order_amount)               as revenue
    from {{ ref('fct_orders') }}
    where is_confirmed
)

select
    s.orders_count                      as source_orders_count,
    m.orders_count                      as mart_orders_count,
    s.revenue                           as source_revenue,
    m.revenue                           as mart_revenue
from source_confirmed as s
cross join mart_confirmed as m
where s.orders_count <> m.orders_count
   or s.revenue <> m.revenue

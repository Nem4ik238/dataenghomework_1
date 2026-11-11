{{ config(distributed_by='customer_id') }}

with customers as (
    select * from {{ ref('stg_shop__customers') }}
),

customer_orders as (
    select * from {{ ref('int_customer_confirmed_orders') }}
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    co.first_confirmed_order_id,
    co.first_confirmed_at,
    coalesce(co.confirmed_orders_count, 0)          as confirmed_orders_count,
    coalesce(co.confirmed_revenue, 0)               as confirmed_revenue,
    coalesce(co.confirmed_orders_count, 0) > 0      as is_buyer
from customers as c
left join customer_orders as co
    on co.customer_id = c.customer_id

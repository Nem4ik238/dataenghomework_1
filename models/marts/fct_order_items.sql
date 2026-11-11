{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        distributed_by='order_id',
        orientation='column'
    )
}}

with order_items as (
    select * from {{ ref('stg_shop__order_items') }}
),

orders as (
    select * from {{ ref('int_orders_with_payments') }}
    where not is_test_order
    {% if is_incremental() %}
      and ordered_at >= (select max(ordered_at) from {{ this }})
    {% endif %}
)

select
    i.order_item_id,
    i.order_id,
    i.product_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    o.is_confirmed,
    i.quantity,
    i.unit_price,
    i.gross_amount,
    i.discount_amount,
    i.line_amount
from order_items as i
join orders as o
    on o.order_id = i.order_id

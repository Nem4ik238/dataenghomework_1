{{ config(severity='warn') }}

select
    order_id,
    customer_id,
    order_amount,
    paid_amount,
    successful_payments_count,
    paid_amount - order_amount          as overcharged_amount
from {{ ref('fct_orders') }}
where is_confirmed
  and paid_amount > order_amount

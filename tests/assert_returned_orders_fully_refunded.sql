select
    order_id,
    order_amount,
    paid_amount,
    refunded_amount,
    net_paid_amount
from {{ ref('fct_orders') }}
where order_status = 'returned'
  and net_paid_amount <> 0

-- Задание 4. Одна строка — один заказ, к нему пристыкованы итоги по платежам.
-- Сначала сверните платежи до заказа (CTE order_payments), потом присоедините их к заказам.
with orders as (
    select * from {{ ref('stg_shop__orders') }}
),

payments as (
    select * from {{ ref('stg_shop__payments') }}
),

order_payments as (
    select
        order_id,
        count(*) filter (where payment_status = 'success' and not is_refund)
                as successful_payments_count,  -- успешные оплаты без возвратов
        coalesce(sum(amount) filter (where payment_status = 'success' and not is_refund), 0)
                as paid_amount,                -- их сумма; 0, если их нет
        coalesce(-sum(amount) filter (where is_refund), 0)
                as refunded_amount,            -- сумма возвратов положительным числом; 0, если их нет
        min(paid_at) filter (where payment_status = 'success' and not is_refund)
                as first_paid_at,              -- время первой успешной оплаты
        {#- Бонус: число операций в каждом статусе — циклом Jinja вместо трёх строк вручную #}
        {%- for status in ['success', 'failed', 'pending'] %}
        count(*) filter (where payment_status = '{{ status }}')
                as {{ status }}_operations_count{{ ',' if not loop.last }}
        {%- endfor %}
    from payments
    group by order_id
),

order_items as (
    select
        order_id,
        count(distinct product_id)          as items_count
    from {{ ref('stg_shop__order_items') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.ordered_at,
    o.order_date,
    o.order_status,
    o.order_amount,
    o.is_test_order,
    coalesce(i.items_count, 0)               as items_count,
    coalesce(p.successful_payments_count, 0) as successful_payments_count,   -- 0 вместо null
    coalesce(p.paid_amount, 0)               as paid_amount,
    coalesce(p.refunded_amount, 0)           as refunded_amount,
    coalesce(p.paid_amount, 0) - coalesce(p.refunded_amount, 0)
                                             as net_paid_amount,             -- оплачено минус возвращено
    p.first_paid_at,
    coalesce(p.success_operations_count, 0)  as success_operations_count,
    coalesce(p.failed_operations_count, 0)   as failed_operations_count,
    coalesce(p.pending_operations_count, 0)  as pending_operations_count,
    o.order_status = 'paid' and coalesce(p.successful_payments_count, 0) > 0
                                             as is_confirmed                 -- статус paid и хотя бы одна успешная оплата
from orders as o
left join order_payments as p
    on p.order_id = o.order_id
left join order_items as i
    on i.order_id = o.order_id

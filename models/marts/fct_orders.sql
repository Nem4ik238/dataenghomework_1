{{ config(distributed_by='order_id') }}
-- Задание 4. Факт заказов: одна строка — один заказ. Тестовые заказы в витрину не попадают.
-- Материализация — table (задана для папки marts в dbt_project.yml).
select
    order_id,
    customer_id,
    order_date,
    ordered_at,
    order_status,
    order_amount,
    items_count,
    paid_amount,
    refunded_amount,
    net_paid_amount,
    successful_payments_count,
    first_paid_at,
    is_confirmed
from {{ ref('int_orders_with_payments') }}
where not is_test_order

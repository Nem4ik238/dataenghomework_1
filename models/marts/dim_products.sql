{{ config(distributed_replicated=true) }}

with products as (
    select * from {{ ref('stg_shop__products') }}
),

categories as (
    select * from {{ ref('int_product_categories_tree') }}
)

select
    p.product_id,
    p.product_name,
    p.brand,
    c.category_id,
    p.category_name,
    c.parent_category_name,
    c.root_category_name,
    c.category_level,
    c.category_path
from products as p
left join categories as c
    on c.category_name = p.category_name

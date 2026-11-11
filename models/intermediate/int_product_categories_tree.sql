with recursive categories as (
    select * from {{ ref('stg_shop__product_categories') }}
),

tree as (
    select
        category_id,
        category_name,
        parent_category_id,
        null::text                      as parent_category_name,
        category_name                   as root_category_name,
        1                               as category_level,
        category_name                   as category_path
    from categories
    where parent_category_id is null

    union all

    select
        c.category_id,
        c.category_name,
        c.parent_category_id,
        t.category_name,
        t.root_category_name,
        t.category_level + 1,
        t.category_path || ' > ' || c.category_name
    from categories as c
    join tree as t
        on c.parent_category_id = t.category_id
)

select
    category_id,
    category_name,
    parent_category_id,
    parent_category_name,
    root_category_name,
    category_level,
    category_path
from tree

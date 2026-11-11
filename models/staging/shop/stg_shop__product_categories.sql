with source as (
    select * from {{ source('shop', 'product_categories') }}
)

select
    category_id,
    parent_category_id,
    category_name
from source

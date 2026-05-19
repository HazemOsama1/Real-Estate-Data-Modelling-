with source as (
    select * from {{ source('realestate', 'property_categories') }}
)
select
    category_id,
    category,
    property_type,
    listing_type,
    offering_type,
    completion_status
from source
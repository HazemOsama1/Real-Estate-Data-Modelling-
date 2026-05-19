with base as (
    select * from {{ ref('stg_property_categories') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['category_id']) }} as property_key,
    category_id                                              as source_category_id,
    category,
    property_type,
    listing_type,
    offering_type,
    completion_status
from base
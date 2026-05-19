with source as (
    select * from {{ source('realestate', 'amenities') }}
)
select
    amenity_id,
    amenity_name
from source
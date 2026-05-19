with source as (
    select * from {{ source('realestate', 'locations') }}
)
select
    location_id,
    city,
    town,
    district,
    subdistrict,
    location_full,
    lat,
    lon,
    created_at
from source
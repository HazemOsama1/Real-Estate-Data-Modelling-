with base as (
    select * from {{ ref('stg_locations') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['location_id']) }} as location_key,
    location_id                                              as source_location_id,
    city,
    town,
    district,
    subdistrict,
    location_full,
    lat,
    lon
from base
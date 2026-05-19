with la as (
    select * from {{ source('realestate', 'listing_amenities') }}
),
amen as (
    select * from {{ ref('stg_amenities') }}
),
fact as (
    select listing_key, source_listing_id from {{ ref('fact_listings') }}
)
select
    f.listing_key,
    a.amenity_id   as amenity_key,
    a.amenity_name
from la
join amen  a on a.amenity_id = la.amenity_id
join fact  f on f.source_listing_id = la.listing_id
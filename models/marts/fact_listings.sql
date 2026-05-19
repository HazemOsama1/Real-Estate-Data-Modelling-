with listings as (
    select * from {{ ref('stg_listings') }}
),
dim_loc as (
    select * from {{ ref('dim_location') }}
),
dim_prop as (
    select * from {{ ref('dim_property') }}
),
dim_ag as (
    select * from {{ ref('dim_agent') }}
),
dim_fl as (
    select * from {{ ref('dim_listing_flags') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['l.listing_id']) }} as listing_key,
    l.listing_id                                              as source_listing_id,

    -- date FK: integer YYYYMMDD so it joins to dim_date.date_key
    cast(
        convert(varchar(8), l.listed_date, 112)
    as int)                                                   as dim_date_key,

    loc.location_key,
    prop.property_key,
    ag.agent_key,
    fl.flags_key,

    -- degenerate dimensions (stay in fact, not worth their own dim)
    l.reference,
    l.rera,
    l.price_currency,
    l.price_period,
    l.payment_method,
    l.area_unit,
    l.furnished,
    l.listing_level,

    -- measures
    l.price_egp,
    l.area_value,
    l.bedrooms,
    l.bathrooms,
    l.images_count,
    l.has_view_360,

    -- audit
    l.listed_date,
    l.scraped_at

from listings l
left join dim_loc  loc  on loc.source_location_id  = l.location_id
left join dim_prop prop on prop.source_category_id = l.category_id
left join dim_ag   ag   on ag.source_agent_id      = l.agent_id
left join dim_fl   fl
       on fl.is_premium          = l.is_premium
      and fl.is_verified         = l.is_verified
      and fl.is_featured         = l.is_featured
      and fl.is_new_construction = l.is_new_construction
      and fl.is_direct_from_dev  = l.is_direct_from_dev
      and fl.is_exclusive        = l.is_exclusive
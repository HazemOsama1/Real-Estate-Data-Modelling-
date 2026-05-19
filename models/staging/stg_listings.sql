with source as (
    select * from {{ source('realestate', 'listings') }}
),
cleaned as (
    select
        listing_id,
        internal_id,
        category_id,
        location_id,
        agent_id,
        title,
        description,
        detail_url,
        reference,
        rera,
        price_egp,
        price_currency,
        price_period,
        payment_method,
        bedrooms,
        bathrooms,
        area_value,
        area_unit,
        furnished,
        listing_level,
        cast(is_premium          as bit) as is_premium,
        cast(is_verified         as bit) as is_verified,
        cast(is_featured         as bit) as is_featured,
        cast(is_new_construction as bit) as is_new_construction,
        cast(is_direct_from_dev  as bit) as is_direct_from_dev,
        cast(is_exclusive        as bit) as is_exclusive,
        images_count,
        cast(has_view_360        as bit) as has_view_360,
        video_url,
        listed_date,
        scraped_at,
        created_at,
        updated_at
    from source
)
select * from cleaned
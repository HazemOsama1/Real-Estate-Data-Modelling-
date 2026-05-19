with flags as (
    select distinct
        is_premium,
        is_verified,
        is_featured,
        is_new_construction,
        is_direct_from_dev,
        is_exclusive
    from {{ ref('stg_listings') }}
)
select
    {{ dbt_utils.generate_surrogate_key([
        'is_premium', 'is_verified', 'is_featured',
        'is_new_construction', 'is_direct_from_dev', 'is_exclusive'
    ]) }}           as flags_key,
    is_premium,
    is_verified,
    is_featured,
    is_new_construction,
    is_direct_from_dev,
    is_exclusive
from flags
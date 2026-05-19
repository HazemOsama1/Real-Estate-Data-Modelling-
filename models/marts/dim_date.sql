select
    date_key,
    cast(full_date as date) as full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_week,
    day_name,
    cast(is_weekend as bit) as is_weekend
from {{ ref('seed_dim_date') }}
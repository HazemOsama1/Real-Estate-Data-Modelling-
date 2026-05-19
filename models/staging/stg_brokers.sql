with source as (
    select * from {{ source('realestate', 'brokers') }}
)
select
    broker_id,
    broker_name,
    broker_email,
    broker_phone,
    created_at,
    updated_at
from source
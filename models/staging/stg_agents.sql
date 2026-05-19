with source as (
    select * from {{ source('realestate', 'agents') }}
)
select
    agent_id,
    agent_name,
    agent_email,
    cast(agent_is_super as bit) as agent_is_super,
    broker_id,
    created_at,
    updated_at
from source
with source as (
    select * from {{ source('realestate', 'agent_languages') }}
),
langs as (
    select * from {{ source('realestate', 'languages') }}
)
select
    al.agent_id,
    l.language_name
from source al
join langs l on l.language_id = al.language_id
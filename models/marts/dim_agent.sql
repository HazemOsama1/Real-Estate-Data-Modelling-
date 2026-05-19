with agents as (
    select * from {{ ref('stg_agents') }}
),
brokers as (
    select * from {{ ref('stg_brokers') }}
),
langs as (
    select
        agent_id,
        string_agg(language_name, ', ')
            within group (order by language_name) as languages
    from {{ ref('stg_agent_languages') }}
    group by agent_id
)
select
    {{ dbt_utils.generate_surrogate_key(['a.agent_id']) }} as agent_key,
    a.agent_id                                              as source_agent_id,
    a.agent_name,
    a.agent_email,
    a.agent_is_super,
    b.broker_id,
    b.broker_name,
    b.broker_email,
    b.broker_phone,
    coalesce(l.languages, 'Unknown')                        as languages
from agents a
left join brokers b on b.broker_id = a.broker_id
left join langs   l on l.agent_id  = a.agent_id
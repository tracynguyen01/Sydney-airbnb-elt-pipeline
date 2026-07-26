{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with src as (
    select distinct
        cast(trim("HOST_ID") as int) as host_id, 
        trim("HOST_NAME") as host_name,

        case
            -- only parse if looks like a valid date (DD/MM/YYYY)
            when "HOST_SINCE" ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                then to_date("HOST_SINCE", 'DD/MM/YYYY')
            else null
        end as host_since,

        trim("HOST_NEIGHBOURHOOD") as host_neighbourhood,
        case 
            when lower("HOST_IS_SUPERHOST") = 't' then true
            when lower("HOST_IS_SUPERHOST") = 'f' then false
            else null
        end as is_superhost
    from {{ ref('b_airbnb') }}
    where "HOST_ID" is not null
)

select
    host_id,
    host_name,
    host_since,
    host_neighbourhood,
    is_superhost
from src

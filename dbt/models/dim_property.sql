{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with raw_property as (
    select distinct
        initcap(trim("PROPERTY_TYPE")) as property_type,
        initcap(trim("ROOM_TYPE")) as room_type,
        cast(trim("ACCOMMODATES") as int) as accommodates,
        cast("SCRAPED_DATE" as date) as scraped_date
    from {{ ref('b_airbnb') }}
    where "PROPERTY_TYPE" is not null
      and "ROOM_TYPE" is not null
      and "ACCOMMODATES" ~ '^[0-9]+$'
)

select
    row_number() over (order by property_type, room_type, accommodates) as property_id,
    property_type,
    room_type,
    accommodates,
    scraped_date
from raw_property
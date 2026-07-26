{{ 
    config(
        unique_key = 'property_id',
        alias = 'dim_property',
        schema = 'gold'
    ) 
}}

with source as (
    select * from {{ ref('s_dim_property') }}
),

cleaned as (
    select
        property_id,
        property_type,
        room_type,
        accommodates,
        case 
            when dbt_valid_from = (select min(dbt_valid_from) from source)
                 then '1900-01-01'::timestamp   -- start of Airbnb data
            else dbt_valid_from
        end as valid_from,
        dbt_valid_to as valid_to
    from source
),

unknown as (
    select
        0 as property_id,
        'Unknown' as property_type,
        'Unknown' as room_type,
        null::int as accommodates,
        '1900-01-01'::timestamp as valid_from,
        null::timestamp as valid_to
)

select * from unknown
union all
select * from cleaned
{{ config(
    unique_key = 'host_id',
    alias = 'dim_host',
    schema = 'gold'
) }}

with source as (
    select * from {{ ref('s_dim_host') }}
),

cleaned as (
    select
        host_id,
        host_name,
        host_since,
        host_neighbourhood,
        is_superhost,
        case
            when dbt_valid_from = (select min(dbt_valid_from) from source)
            then '1900-01-01'::timestamp
            else dbt_valid_from
        end as valid_from,
        dbt_valid_to as valid_to
    from source
),

unknown as (
    select
        0 as host_id,
        'unknown' as host_name,
        null::date as host_since,
        'unknown' as host_neighbourhood,
        false as is_superhost,
        '1900-01-01'::timestamp as valid_from,
        null::timestamp as valid_to
)

select * from unknown
union all
select * from cleaned

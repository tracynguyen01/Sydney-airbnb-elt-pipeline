{{
    config(
        unique_key = 'suburb_name',
        alias = 'dim_suburb',
        schema = 'gold'
    )
}}

with source as (
    -- use snapshot for historical suburb records
    select *
    from {{ ref('s_dim_suburb') }}
),

lga as (
    -- enriched LGA info from the gold layer
    select
        lga_code,
        lga_name,
        median_age_persons,
        median_income_weekly,
        median_household_income_weekly,
        avg_household_size
    from {{ ref('g_dim_lga') }}
),

cleaned as (
    select
        s.suburb_name,
        s.lga_name,
        l.lga_code,
        l.median_age_persons,
        l.median_income_weekly,
        l.median_household_income_weekly,
        l.avg_household_size,
        case 
            when s.dbt_valid_from = (select min(dbt_valid_from) from source)
                then '1900-01-01'::timestamp
            else s.dbt_valid_from
        end as valid_from,
        s.dbt_valid_to as valid_to
    from source s
    left join lga l
        on lower(s.lga_name) = lower(l.lga_name)
),

unknown as (
    select
        'Unknown' as suburb_name,
        'Unknown' as lga_name,
        0 as lga_code,
        null::int as median_age_persons,
        null::int as median_income_weekly,
        null::int as median_household_income_weekly,
        null::numeric(5,2) as avg_household_size,
        '1900-01-01'::timestamp as valid_from,
        null::timestamp as valid_to
)

select * from unknown
union all
select * from cleaned

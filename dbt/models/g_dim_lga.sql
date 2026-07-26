{{
    config(
        unique_key = 'lga_code',
        alias = 'dim_lga',
        schema = 'gold'
    )
}}

with source as (
    -- Use the snapshot to keep historical versions
    select * 
    from {{ ref('s_dim_lga') }}
),

census_g01 as (
    select 
        lga_code,
        total_population,
        australian_citizen,
        indigenous_population,
        yr12_completion
    from {{ ref('dim_census_g01') }}
),

census_g02 as (
    select 
        lga_code,
        median_income_weekly,
        median_age_persons,
        median_family_income_weekly,
        median_household_income_weekly,
        avg_persons_per_bedroom,
        avg_household_size
    from {{ ref('dim_census_g02') }}
),

cleaned as (
    select
        s.lga_code,
        s.lga_name,
        g01.total_population,
        g01.australian_citizen,
        g01.indigenous_population,
        g01.yr12_completion,
        g02.median_income_weekly,
        g02.median_age_persons,
        g02.median_family_income_weekly,
        g02.median_household_income_weekly,
        g02.avg_persons_per_bedroom,
        g02.avg_household_size,
        case 
            when s.dbt_valid_from = (select min(dbt_valid_from) from source)
                then '1900-01-01'::timestamp
            else s.dbt_valid_from
        end as valid_from,
        s.dbt_valid_to as valid_to
    from source s
    left join census_g01 g01 on s.lga_code = g01.lga_code
    left join census_g02 g02 on s.lga_code = g02.lga_code
),

unknown as (
    select
        0 as lga_code,
        'Unknown' as lga_name,
        null::int as total_population,
        null::int as median_age_persons,
        null::int as australian_citizen,
        null::int as indigenous_population,
        null::int as yr12_completion,
        null::int as median_income_weekly,
        null::int as median_family_income_weekly,
        null::int as median_household_income_weekly,
        null::numeric(5,2) as avg_persons_per_bedroom,
        null::numeric(5,2) as avg_household_size,
        '1900-01-01'::timestamp as valid_from,
        null::timestamp as valid_to
)

select * from unknown
union all
select * from cleaned

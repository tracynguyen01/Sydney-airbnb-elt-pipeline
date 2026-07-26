{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with raw_g01 as (
    select
        cast(regexp_replace(trim("LGA_CODE_2016"), '[^0-9]', '', 'g') as int) as lga_code,
        cast(nullif("Tot_P_M",'') as int) as tot_male,
        cast(nullif("Tot_P_F",'') as int) as tot_female,
        cast(nullif("Tot_P_P",'') as int) as total_population,
        cast(nullif("Counted_Census_Night_home_M",'') as int) as census_home_male,
        cast(nullif("Counted_Census_Night_home_F",'') as int) as census_home_female,
        cast(nullif("Australian_citizen_P",'') as int) as australian_citizen,
        cast(nullif("Indigenous_psns_Aboriginal_P",'') as int) as indigenous_population,
        cast(nullif("High_yr_schl_comp_Yr_12_eq_P",'') as int) as yr12_completion,
        cast(nullif("Count_psns_occ_priv_dwgs_P",'') as int) as private_dwelling_population
    from {{ ref('b_census_g01') }}
    where "LGA_CODE_2016" is not null
)

select 
    lga_code,
    tot_male,
    tot_female,
    total_population,
    census_home_male,
    census_home_female,
    australian_citizen,
    indigenous_population,
    yr12_completion,
    private_dwelling_population
from raw_g01
{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with raw_g02 as (
    select
        cast(regexp_replace(trim("LGA_CODE_2016"), '[^0-9]', '', 'g') as int) as lga_code,
        cast(nullif("Median_age_persons",'') as int) as median_age_persons,
        cast(nullif("Median_mortgage_repay_monthly",'') as int) as median_mortgage_repay_monthly,
        cast(nullif("Median_tot_prsnl_inc_weekly",'') as int) as median_income_weekly,
        cast(nullif("Median_rent_weekly",'') as int) as median_rent_weekly,
        cast(nullif("Median_tot_fam_inc_weekly",'') as int) as median_family_income_weekly,
        cast(nullif("Average_num_psns_per_bedroom",'') as numeric(5,2)) as avg_persons_per_bedroom,
        cast(nullif("Median_tot_hhd_inc_weekly",'') as int) as median_household_income_weekly,
        cast(nullif("Average_household_size",'') as numeric(5,2)) as avg_household_size
    from {{ ref('b_census_g02') }}
    where "LGA_CODE_2016" is not null
)

select 
    lga_code,
    median_age_persons,
    median_mortgage_repay_monthly,
    median_income_weekly,
    median_rent_weekly,
    median_family_income_weekly,
    avg_persons_per_bedroom,
    median_household_income_weekly,
    avg_household_size
from raw_g02

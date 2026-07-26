{% snapshot s_dim_census_g02 %}
{{
    config(
        target_schema='silver',
        unique_key='lga_code',
        strategy='check',
        check_cols=[
            'median_age_persons',
            'median_mortgage_repay_monthly',
            'median_income_weekly',
            'median_rent_weekly',
            'median_family_income_weekly',
            'avg_persons_per_bedroom',
            'median_household_income_weekly',
            'avg_household_size'
        ]
    )
}}

select
    cast(lga_code as int) as lga_code,
    median_age_persons,
    median_mortgage_repay_monthly,
    median_income_weekly,
    median_rent_weekly,
    median_family_income_weekly,
    avg_persons_per_bedroom,
    median_household_income_weekly,
    avg_household_size
from {{ ref('dim_census_g02') }}

{% endsnapshot %} 

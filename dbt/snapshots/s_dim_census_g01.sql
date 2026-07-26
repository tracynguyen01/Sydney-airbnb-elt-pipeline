{% snapshot s_dim_census_g01 %}
{{
    config(
        target_schema='silver',
        unique_key='lga_code',
        strategy='check',
        check_cols=[
            'tot_male',
            'tot_female',
            'total_population',
            'australian_citizen',
            'indigenous_population',
            'yr12_completion',
            'private_dwelling_population'
        ]
    )
}}

select
    cast(lga_code as int) as lga_code,
    tot_male,
    tot_female,
    total_population,
    australian_citizen,
    indigenous_population,
    yr12_completion,
    private_dwelling_population
from {{ ref('dim_census_g01') }}

{% endsnapshot %} 
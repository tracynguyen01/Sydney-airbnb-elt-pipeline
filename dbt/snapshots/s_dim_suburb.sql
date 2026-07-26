{% snapshot s_dim_suburb %}
{{
    config(
        target_schema='silver',
        unique_key='suburb_name',
        strategy='check',
        check_cols=['lga_name', 'lga_code']
    )
}}

select
    suburb_name,
    lga_name,
    lga_code
from {{ ref('dim_suburb') }}

{% endsnapshot %}

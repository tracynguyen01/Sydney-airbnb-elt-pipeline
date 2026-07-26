{% snapshot s_dim_lga %}
{{
    config(
        target_schema='silver',
        unique_key='lga_code',
        strategy='check',
        check_cols=['lga_name']
    )
}}

select
    lga_code,
    lga_name
from {{ ref('dim_lga') }}

{% endsnapshot %}

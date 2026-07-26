{% snapshot s_dim_property %}
{{ config(
    target_schema = 'silver',
    unique_key = 'property_id',
    strategy = 'timestamp',
    updated_at = 'scraped_date'
) }}

select
    property_id,
    property_type,
    room_type,
    accommodates,
    scraped_date
from {{ ref('dim_property') }}

{% endsnapshot %}

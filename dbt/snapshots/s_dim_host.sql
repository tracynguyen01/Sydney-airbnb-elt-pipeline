{% snapshot s_dim_host %}
{{ config(
    target_schema = 'silver',
    unique_key = 'host_id',
    strategy = 'timestamp',
    updated_at = 'host_since'
) }}

select
    cast(host_id as int) as host_id,
    host_name,
    host_since,
    host_neighbourhood,
    is_superhost
from {{ ref('dim_host') }}

{% endsnapshot %} 

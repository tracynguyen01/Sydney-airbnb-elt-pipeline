{{ config(
    materialized = 'view',
    schema = 'gold'
) }}

with base as (
    select 
        lga_name as host_neighbourhood_lga,
        month,
        year,
        count(distinct host_id) as distinct_hosts,
        round(avg(estimated_revenue),2) as est_revenue_per_active_listing,
        round(sum(estimated_revenue) / nullif(count(distinct host_id),0),2) as est_revenue_per_host
    from {{ ref('g_fact_listing') }}
    where lga_name is not null
    group by lga_name, month, year
)
select *
from base
order by host_neighbourhood_lga, month, year

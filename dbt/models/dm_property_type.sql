{{ config(
    materialized = 'view',
    schema = 'gold'
) }}

with base as (
    select 
        property_type,
        room_type,
        accommodates,
        month,
        year,
        count(distinct listing_id) as total_listings,
        count(distinct case when is_active = 1 then listing_id end) as active_listings,
        round((count(distinct case when is_active = 1 then listing_id end) * 100.0) /
              nullif(count(distinct listing_id),0), 2) as active_listing_rate,
        round(min(case when is_active = 1 then price end), 2) as min_price,
        round(max(case when is_active = 1 then price end), 2) as max_price,
        percentile_cont(0.5) within group (order by case when is_active = 1 then price end) as median_price,
        round(avg(case when is_active = 1 then price end), 2) as avg_price,
        count(distinct host_id) as distinct_hosts,
        round(avg(case when is_superhost = true then 1 else 0 end)*100,2) as superhost_rate,

        round(avg(review_rating),2) as avg_review_score,
        sum(estimated_revenue) as total_estimated_revenue,
        round(avg(estimated_revenue),2) as avg_estimated_revenue_per_active_listing,
        sum(is_active * availability_30) as total_stays

    from {{ ref('g_fact_listing') }}
    group by property_type, room_type, accommodates, month, year
)

select *
from base
order by property_type, room_type, accommodates, month, year
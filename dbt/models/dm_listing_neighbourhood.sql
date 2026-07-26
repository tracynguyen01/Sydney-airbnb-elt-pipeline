{{ config(
    materialized = 'view',
    schema = 'gold'
) }}

with base as (
    select 
        suburb_name as listing_neighbourhood,
        month,
        year,
        count(distinct listing_id) as total_listings,
        COUNT(DISTINCT CASE WHEN is_active = 1 THEN listing_id END) AS active_listings,
        count(distinct case when is_active = 0 then listing_id end) as inactive_listings,
        round(100.0 * count(distinct case when is_active = 1 then listing_id end) / nullif(count(distinct listing_id), 0), 2) as active_listing_rate,
        ROUND(MIN(CASE WHEN is_active = 1 THEN price END), 2) AS min_price,
        ROUND(MAX(CASE WHEN is_active = 1 THEN price END), 2) AS max_price,
        ROUND(AVG(CASE WHEN is_active = 1 THEN price END), 2) AS avg_price,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CASE WHEN is_active = 1 THEN price END)AS median_price,
        count(distinct host_id) as distinct_hosts,
        round(100.0 * count(distinct case when is_superhost = 't' then host_id end) / nullif(count(distinct host_id), 0), 2) as superhost_rate,
        round(avg(review_rating),2) as avg_review_score,        
        sum(is_active) as total_active_listings,
        sum(is_active * availability_30) as total_stays,
        round(avg(estimated_revenue),2) as avg_estimated_revenue_per_active_listing
    from {{ ref('g_fact_listing') }}
    where suburb_name is not null
    group by suburb_name, month, year
)
select * from base
order by listing_neighbourhood, month, year

{{ config(
    materialized = 'table',
    schema = 'gold'
) }}

-- ==============================================================
-- Optimized Gold Fact Table: g_fact_listing
-- Purpose: Join Airbnb listing facts with Gold-layer dimensions
-- ==============================================================

with base as (
    select
        f.listing_id,
        f.host_id,
        f.suburb_name,
        f.property_type,
        f.room_type,
        f.accommodates,
        f.price,
        f.is_active,
        f.availability_30,
        f.num_reviews,
        f.review_rating,
        f.review_cleanliness,
        f.review_accuracy,
        f.review_communication,
        f.review_value,
        f.scraped_date
    from {{ ref('fact_listing') }} f
    limit 50000   -- limit for testing to avoid memory overflow
),

-- Join suburb → enrich with LGA demographics
add_suburb as (
    select
        b.listing_id,
        b.host_id,
        b.suburb_name,
        b.property_type,
        b.room_type,
        b.accommodates,
        b.price,
        b.is_active,
        b.availability_30,
        b.num_reviews,
        b.review_rating,
        b.review_cleanliness,
        b.review_accuracy,
        b.review_communication,
        b.review_value,
        b.scraped_date,
        s.lga_code,
        s.lga_name,
        s.median_age_persons,
        s.median_income_weekly,
        s.median_household_income_weekly,
        s.avg_household_size
    from base b
    left join {{ ref('g_dim_suburb') }} s
        on lower(trim(b.suburb_name)) = lower(trim(s.suburb_name))
),

-- Join host → add host details
add_host as (
    select
        a.listing_id,
        a.host_id,
        a.suburb_name,
        a.lga_code,
        a.lga_name,
        a.property_type,
        a.room_type,
        a.accommodates,
        a.price,
        a.is_active,
        a.availability_30,
        a.num_reviews,
        a.review_rating,
        a.review_cleanliness,
        a.review_accuracy,
        a.review_communication,
        a.review_value,
        a.scraped_date,
        a.median_age_persons,
        a.median_income_weekly,
        a.median_household_income_weekly,
        a.avg_household_size,
        h.host_name,
        h.host_since,
        h.host_neighbourhood,
        h.is_superhost
    from add_suburb a
    left join {{ ref('g_dim_host') }} h
        on a.host_id = h.host_id
),

-- Join property → ensure consistent property mapping
add_property as (
    select
        coalesce(p.property_id, 0) as property_id,
        f.listing_id,
        f.host_id,
        coalesce(f.suburb_name, 'Unknown') as suburb_name,
        f.lga_code,
        f.lga_name,
        coalesce(p.property_type, f.property_type) as property_type,
        coalesce(p.room_type, f.room_type) as room_type,
        coalesce(p.accommodates, f.accommodates) as accommodates,
        f.price,
        f.is_active,
        f.availability_30,
        f.num_reviews,
        f.review_rating,
        f.review_cleanliness,
        f.review_accuracy,
        f.review_communication,
        f.review_value,
        f.scraped_date,
        f.host_name,
        f.host_since,
        f.host_neighbourhood,
        f.is_superhost,
        f.median_age_persons,
        f.median_income_weekly,
        f.median_household_income_weekly,
        f.avg_household_size
    from add_host f
    left join {{ ref('g_dim_property') }} p
        on lower(trim(f.property_type)) = lower(trim(p.property_type))
),

-- Add revenue & time attributes
final as (
    select
        listing_id,
        host_id,
        property_id,
        suburb_name,
        lga_code,
        lga_name,
        property_type,
        room_type,
        accommodates,
        price,
        is_active,
        availability_30,
        num_reviews,
        review_rating,
        review_cleanliness,
        review_accuracy,
        review_communication,
        review_value,
        scraped_date,
        host_name,
        host_since,
        host_neighbourhood,
        is_superhost,
        median_age_persons,
        median_income_weekly,
        median_household_income_weekly,
        avg_household_size,
        round(coalesce(price * is_active, 0), 2) as estimated_revenue,
        extract(year from scraped_date) as year,
        extract(month from scraped_date) as month
    from add_property
    where price is not null
)

select * from final

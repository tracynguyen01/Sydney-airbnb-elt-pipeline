{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with listing as (
    select
        cast("LISTING_ID" as int) as listing_id,
        cast("HOST_ID" as int) as host_id,
        trim("LISTING_NEIGHBOURHOOD") as suburb_name,
        trim("PROPERTY_TYPE") as property_type,
        trim("ROOM_TYPE") as room_type,
        cast(nullif("ACCOMMODATES",'') as int) as accommodates,
        cast(nullif("PRICE",'') as numeric(10,2)) as price,
        case when "HAS_AVAILABILITY" = 't' then 1 else 0 end as is_active,
        cast(nullif("AVAILABILITY_30",'') as int) as availability_30,
        cast(nullif("NUMBER_OF_REVIEWS",'') as int) as num_reviews,
        cast(nullif("REVIEW_SCORES_RATING",'') as numeric(5,2)) as review_rating,
        cast(nullif("REVIEW_SCORES_CLEANLINESS",'') as numeric(5,2)) as review_cleanliness,
        cast(nullif("REVIEW_SCORES_ACCURACY",'') as numeric(5,2)) as review_accuracy,
        cast(nullif("REVIEW_SCORES_COMMUNICATION",'') as numeric(5,2)) as review_communication,
        cast(nullif("REVIEW_SCORES_VALUE",'') as numeric(5,2)) as review_value,
        cast(nullif("SCRAPED_DATE",'') as date) as scraped_date
    from {{ ref('b_airbnb') }}
)

select *
from listing
where price is not null

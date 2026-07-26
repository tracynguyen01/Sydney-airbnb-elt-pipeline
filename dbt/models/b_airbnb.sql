{{
    config(
        unique_key='LISTING_ID',
        alias='airbnb'
    )
}}
select * from {{ source('raw', 'airbnb_raw') }}
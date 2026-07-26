{{
    config(
        unique_key='LGA_CODE_2016',
        alias='go1'
    )
}}
select * from {{ source('raw', 'census_g01_raw') }}
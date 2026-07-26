{{
    config(
        unique_key='LGA_CODE_2016',
        alias='go2'
    )
}}
select * from {{ source('raw', 'census_g02_raw') }}

{{
    config(
        unique_key='SUBURB_NAME',
        alias='suburb'
    )
}}
select * from {{ source('raw', 'lga_suburb_mapping_raw') }}
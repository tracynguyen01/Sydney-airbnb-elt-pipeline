{{
    config(
        unique_key='LGA_CODE',
        alias='code'
    )
}}
select * from {{ source('raw', 'lga_code_mapping_raw') }}
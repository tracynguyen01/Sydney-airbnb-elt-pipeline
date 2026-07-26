{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

select distinct
    cast("LGA_CODE" as int) as lga_code,
    initcap(trim("LGA_NAME")) as lga_name
from {{ ref('b_lga_code_mapping') }}
where "LGA_CODE" is not null
  and "LGA_NAME" is not null
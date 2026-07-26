{{ config(
    materialized = 'table',
    schema = 'silver'
) }}

with suburb_lga as (
    select distinct
        initcap(trim("SUBURB_NAME")) as suburb_name,
        initcap(trim("LGA_NAME")) as lga_name
    from {{ ref('b_lga_suburb_mapping') }}
    where "SUBURB_NAME" is not null
),

lga_code as (
    select distinct
        initcap(trim("LGA_NAME")) as lga_name,
        cast("LGA_CODE" as int) as lga_code
    from {{ ref('b_lga_code_mapping') }}
    where "LGA_NAME" is not null
)

select
    s.suburb_name,
    s.lga_name,
    l.lga_code
from suburb_lga s
left join lga_code l
    on lower(s.lga_name) = lower(l.lga_name)

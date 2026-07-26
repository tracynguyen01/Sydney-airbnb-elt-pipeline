-- 4(a) Demographic differences between Top 3 and Bottom 3 LGAs
WITH bounds AS (
    SELECT 
        date_trunc('month', max(scraped_date)) AS anchor_month
    FROM bde_dbt_gold.g_fact_listing
),
win AS (
    SELECT 
        (anchor_month - INTERVAL '11 months')::date AS start_date,
        (anchor_month + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_date
    FROM bounds
),
lga_perf AS (
    SELECT
        lga_code,
        lga_name,

        -- Business metric: average revenue per active listing
        AVG(CASE WHEN is_active = 1 THEN estimated_revenue END) AS avg_rev_per_active,

        -- Available demographic metrics
        AVG(median_income_weekly)            AS median_income_weekly,
        AVG(median_household_income_weekly)  AS median_household_income_weekly,
        AVG(avg_household_size)              AS avg_household_size
    FROM bde_dbt_gold.g_fact_listing f
    JOIN win w 
        ON f.scraped_date BETWEEN w.start_date AND w.end_date
    WHERE lga_code IS NOT NULL
    GROUP BY lga_code, lga_name
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY avg_rev_per_active DESC) AS rnk_desc,
           DENSE_RANK() OVER (ORDER BY avg_rev_per_active ASC)  AS rnk_asc
    FROM lga_perf
)
SELECT
    CASE
        WHEN rnk_desc <= 3 THEN 'TOP 3'
        WHEN rnk_asc  <= 3 THEN 'BOTTOM 3'
    END AS performance_group,
    lga_name,
    round(avg_rev_per_active, 2)             AS avg_rev_per_active,
    round(median_income_weekly, 2)           AS median_income_weekly,
    round(median_household_income_weekly, 2) AS median_household_income_weekly,
    round(avg_household_size, 2)             AS avg_household_size
FROM ranked
WHERE rnk_desc <= 3 OR rnk_asc <= 3
ORDER BY performance_group, avg_rev_per_active DESC;


-- 4b.correlation between the median age of a neighbourhood and the revenue generated per active listing in that neighbourhood
WITH bounds AS (
    SELECT 
        date_trunc('month', max(scraped_date)) AS anchor_month
    FROM bde_dbt_gold.g_fact_listing
),
win AS (
    SELECT
        (anchor_month - INTERVAL '11 months')::date AS start_date,
        (anchor_month + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_date
    FROM bounds
),
neigh AS (
    SELECT
        lower(suburb_name) AS listing_neighbourhood,
        round(avg(median_age_persons)::numeric, 1) AS median_age,
        round(avg(CASE WHEN is_active = 1 THEN estimated_revenue END)::numeric, 2) AS avg_rev_active
    FROM bde_dbt_gold.g_fact_listing f
    JOIN win w 
        ON f.scraped_date BETWEEN w.start_date AND w.end_date
    WHERE suburb_name IS NOT NULL
    GROUP BY suburb_name
)
SELECT
    n.listing_neighbourhood,
    n.median_age,
    n.avg_rev_active,
    round(corr(n.avg_rev_active, n.median_age) OVER ()::numeric, 4) AS r,
    round(power(corr(n.avg_rev_active, n.median_age) OVER (), 2)::numeric, 4) AS r2,
    round(regr_slope(n.avg_rev_active, n.median_age) OVER ()::numeric, 4) AS slope
FROM neigh n
group by n.listing_neighbourhood, n.median_age , n.avg_rev_active
ORDER BY n.median_age;


-- 4c the best type of listing for the top 5 “listing_neighbourhood” to have the highest number of stays
WITH bounds AS (
  SELECT date_trunc('month', max(scraped_date)) AS anchor_month
  FROM bde_dbt_gold.g_fact_listing
),
win AS (
  SELECT (anchor_month - INTERVAL '11 months')::date AS start_date,
         (anchor_month + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_date
  FROM bounds
),
top5 AS (  -- top 5 neighbourhoods by revenue per active
  SELECT suburb_name AS listing_neighbourhood,
         AVG(CASE WHEN is_active = 1 THEN estimated_revenue END) AS avg_rev_per_active
  FROM bde_dbt_gold.g_fact_listing f
  JOIN win w ON f.scraped_date BETWEEN w.start_date AND w.end_date
  WHERE suburb_name IS NOT NULL
  GROUP BY suburb_name
  ORDER BY avg_rev_per_active DESC
  LIMIT 5
),
combo AS (
  SELECT
    f.suburb_name AS listing_neighbourhood,
    f.property_type,
    f.room_type,
    f.accommodates,
    SUM(CASE WHEN is_active = 1 THEN 30 - availability_30 ELSE 0 END) AS total_stays
  FROM bde_dbt_gold.g_fact_listing f
  JOIN win w ON f.scraped_date BETWEEN w.start_date AND w.end_date
  JOIN top5 t ON t.listing_neighbourhood = f.suburb_name
  GROUP BY 1,2,3,4
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY listing_neighbourhood
                            ORDER BY total_stays DESC) AS rnk
  FROM combo
)
SELECT listing_neighbourhood, property_type, room_type, accommodates, total_stays
FROM ranked
WHERE rnk = 1
ORDER BY listing_neighbourhood;

--4d For hosts with multiple listings are their properties concentrated within the same LGA, or are they distributed across different LGAs?
WITH bounds AS (
  SELECT date_trunc('month', max(scraped_date)) AS anchor_month
  FROM bde_dbt_gold.g_fact_listing
),
win AS (
  SELECT (anchor_month - INTERVAL '11 months')::date AS start_date,
         (anchor_month + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_date
  FROM bounds
),
host_scope AS (
  SELECT
    host_id,
    COUNT(DISTINCT listing_id) AS listings,
    COUNT(DISTINCT lga_code)   AS lga_count
  FROM bde_dbt_gold.g_fact_listing f
  JOIN win w ON f.scraped_date BETWEEN w.start_date AND w.end_date
  GROUP BY host_id
  HAVING COUNT(DISTINCT listing_id) >= 2   -- multi-listing only
)
SELECT
  CASE WHEN lga_count = 1 THEN 'Concentrated (1 LGA)'
       ELSE 'Distributed (multiple LGAs)'
  END AS distribution,
  COUNT(*) AS host_count
FROM host_scope
GROUP BY 1
ORDER BY host_count DESC;

-- 4e For hosts with a single Airbnb listing does the estimated revenue over the last 12 months cover the annualised median mortgage repayment in the corresponding LGA?
-- Which LGA has the highest percentage of hosts that can cover it?
WITH bounds AS (
  SELECT date_trunc('month', max(scraped_date)) AS anchor_month
  FROM bde_dbt_gold.g_fact_listing
),
win AS (
  SELECT (anchor_month - INTERVAL '11 months')::date AS start_date,
         (anchor_month + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_date
  FROM bounds
),
single_hosts AS (
  SELECT host_id
  FROM bde_dbt_gold.g_fact_listing f
  JOIN win w ON f.scraped_date BETWEEN w.start_date AND w.end_date
  GROUP BY host_id
  HAVING COUNT(DISTINCT listing_id) = 1
),
host_rev AS (
  SELECT
    f.host_id,
    f.lga_code,
    SUM(estimated_revenue) AS revenue_12m
  FROM bde_dbt_gold.g_fact_listing f
  JOIN single_hosts s USING (host_id)
  JOIN win w ON f.scraped_date BETWEEN w.start_date AND w.end_date
  GROUP BY f.host_id, f.lga_code
),
with_income AS (
  SELECT
    h.host_id,
    h.lga_code,
    l.lga_name,
    h.revenue_12m,
    (52 * l.median_household_income_weekly) AS household_income_annual
  FROM host_rev h
  JOIN bde_dbt_gold.dim_lga l USING (lga_code)
),
flagged AS (
  SELECT *,
         (revenue_12m >= household_income_annual)::int AS can_cover
  FROM with_income
)
SELECT
  lga_name,
  COUNT(*)                               AS single_hosts,
  SUM(can_cover)                         AS hosts_cover_income,
  ROUND(100.0 * SUM(can_cover) / NULLIF(COUNT(*),0), 2) AS pct_covering
FROM flagged
GROUP BY lga_name
ORDER BY pct_covering DESC, single_hosts DESC
LIMIT 10;








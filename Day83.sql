/*
Problem 1 — Brand Share of Voice (SoV) by State (monthly)

Question: For each state and month, find brands’ Share of Voice (SoV) defined as brand_impressions / total_state_impressions. Return top 5 brands per state by SoV for the last 3 months.

*/


WITH monthly AS (
  SELECT
    date_trunc('month', serp_date) AS month,
    state,
    brand,
    SUM(impressions) AS brand_impressions
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '3 months'
  GROUP BY 1,2,3
),

state_totals AS (
  SELECT
    month,
    state,
    SUM(brand_impressions) AS state_impressions
  FROM monthly
  GROUP BY month, state
),

joined AS (
  SELECT
    m.month,
    m.state,
    m.brand,
    m.brand_impressions,
    s.state_impressions,
    (m.brand_impressions::float / NULLIF(s.state_impressions,0)) AS sov
  FROM monthly m
  JOIN state_totals s USING (month, state)
),

ranked AS (
  SELECT
    month,
    state,
    brand,
    brand_impressions,
    round(sov::numeric, 4) AS sov,
    ROW_NUMBER() OVER (PARTITION BY month, state ORDER BY sov DESC, brand) AS rn
  FROM joined
)
SELECT month, state, brand, brand_impressions, sov
FROM ranked
WHERE rn <= 5
ORDER BY month DESC, state, sov DESC;


---Alternative
WITH monthly AS (
  SELECT
    date_trunc('month', serp_date) AS month,
    state,
    brand,
    SUM(impressions) AS brand_impressions
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '3 months'
  GROUP BY 1,2,3
),

state_totals AS (
  SELECT
    month,
    state,
    SUM(brand_impressions) AS state_impressions
  FROM monthly
  GROUP BY month, state
),

joined AS (
  SELECT
    m.month,
    m.state,
    m.brand,
    m.brand_impressions,
    s.state_impressions,
    (m.brand_impressions::float / NULLIF(s.state_impressions,0)) AS sov
  FROM monthly m
  JOIN state_totals s USING (month, state)
),

rank_pairs AS (
  SELECT
    j1.month,
    j1.state,
    j1.brand,
    j1.brand_impressions,
    ROUND(j1.sov::numeric,4) AS sov,
    COUNT(DISTINCT j2.brand) FILTER (WHERE j2.sov > j1.sov) AS higher_count
  FROM joined j1
  LEFT JOIN joined j2
    ON j1.month = j2.month
   AND j1.state = j2.state
  GROUP BY j1.month, j1.state, j1.brand, j1.brand_impressions, j1.sov
)
SELECT month, state, brand, brand_impressions, sov
FROM rank_pairs
WHERE higher_count < 5
ORDER BY month DESC, state, sov DESC;


/*
Problem 2 — Monthly SoV Growth (brand trend) and top gainers

Question: For the last 2 months, find brands per state whose SoV grew the most month-over-month. Return brand, state, prev_sov, curr_sov, growth_pct and top 10 improvements overall.
*/

WITH monthly_sov AS (
  SELECT
    date_trunc('month', serp_date) AS month,
    state,
    brand,
    SUM(impressions) AS brand_impr
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '2 months'
  GROUP BY 1,2,3
),
state_totals AS (
  SELECT month, state, SUM(brand_impr) AS state_impr
  FROM monthly_sov
  GROUP BY month, state
),
sov AS (
  SELECT
    m.month,
    m.state,
    m.brand,
    m.brand_impr,
    (m.brand_impr::float / NULLIF(s.state_impr,0)) AS sov
  FROM monthly_sov m
  JOIN state_totals s USING (month, state)
),
sov_with_lag AS (
  SELECT
    month,
    state,
    brand,
    sov,
    LAG(sov) OVER (PARTITION BY state, brand ORDER BY month) AS prev_sov
  FROM sov
)
SELECT
  s.month,
  s.state,
  s.brand,
  round(s.prev_sov::numeric,4) AS prev_sov,
  round(s.sov::numeric,4) AS curr_sov,
  CASE
    WHEN s.prev_sov IS NULL OR s.prev_sov = 0 THEN NULL
    ELSE round(((s.sov - s.prev_sov) / s.prev_sov)::numeric,4)
  END AS growth_pct
FROM sov_with_lag s
WHERE s.prev_sov IS NOT NULL -- only compare months that have previous month
ORDER BY growth_pct DESC NULLS LAST
LIMIT 10;

--Alternative

WITH monthly_sov AS (
  SELECT
    date_trunc('month', serp_date) AS month,
    state,
    brand,
    SUM(impressions) AS brand_impr
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '2 months'
  GROUP BY 1,2,3
),
state_totals AS (
  SELECT month, state, SUM(brand_impr) AS state_impr
  FROM monthly_sov
  GROUP BY month, state
),
sov AS (
  SELECT
    m.month,
    m.state,
    m.brand,
    (m.brand_impr::float / NULLIF(s.state_impr,0)) AS sov
  FROM monthly_sov m
  JOIN state_totals s USING (month, state)
),
-- self-join current month to previous month (month - 1 month)
pairs AS (
  SELECT
    curr.month AS curr_month,
    curr.state,
    curr.brand,
    prev.sov AS prev_sov,
    curr.sov AS curr_sov
  FROM sov curr
  JOIN sov prev
    ON curr.brand = prev.brand
   AND curr.state = prev.state
   AND curr.month = prev.month + INTERVAL '1 month'
)
SELECT
  curr_month,
  state,
  brand,
  round(prev_sov::numeric,4) AS prev_sov,
  round(curr_sov::numeric,4) AS curr_sov,
  CASE WHEN prev_sov = 0 THEN NULL ELSE round(((curr_sov - prev_sov) / prev_sov)::numeric,4) END AS growth_pct
FROM pairs
ORDER BY growth_pct DESC NULLS LAST
LIMIT 10;


/*
Problem 3 — Keyword Position Improvements for a Dealership (keyword-level)

Question: For a given dealership (or all dealerships), find keywords where the average position improved by ≥ 3 positions month-over-month, and only consider keywords with at least 5 impressions each month. Return dealership_id, keyword, prev_pos, curr_pos, improvement.
*/

WITH agg AS (
  SELECT
    dealership_id,
    keyword,
    date_trunc('month', serp_date) AS month,
    AVG(position)::numeric AS avg_pos,
    SUM(impressions) AS impressions
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '2 months'
  GROUP BY dealership_id, keyword, date_trunc('month', serp_date)
),
filtered AS (
  SELECT *
  FROM agg
  WHERE impressions >= 5
),
with_prev AS (
  SELECT
    dealership_id,
    keyword,
    month,
    avg_pos,
    LAG(avg_pos) OVER (PARTITION BY dealership_id, keyword ORDER BY month) AS prev_avg_pos
  FROM filtered
)
SELECT
  dealership_id,
  keyword,
  round(prev_avg_pos::numeric,2) AS prev_pos,
  round(avg_pos::numeric,2) AS curr_pos,
  round(prev_avg_pos - avg_pos::numeric,2) AS improvement
FROM with_prev
WHERE prev_avg_pos IS NOT NULL
  AND (prev_avg_pos - avg_pos) >= 3
ORDER BY improvement DESC;


--Alternative
WITH agg AS (
  SELECT
    dealership_id,
    keyword,
    date_trunc('month', serp_date) AS month,
    AVG(position)::numeric AS avg_pos,
    SUM(impressions) AS impressions
  FROM dealer_serp
  WHERE serp_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '2 months'
  GROUP BY dealership_id, keyword, date_trunc('month', serp_date)
),
filtered AS (
  SELECT *
  FROM agg
  WHERE impressions >= 5
),
pairs AS (
  SELECT
    curr.dealership_id,
    curr.keyword,
    prev.avg_pos AS prev_avg_pos,
    curr.avg_pos AS curr_avg_pos
  FROM filtered curr
  JOIN filtered prev
    ON curr.dealership_id = prev.dealership_id
   AND curr.keyword = prev.keyword
   AND curr.month = prev.month + INTERVAL '1 month'
)
SELECT
  dealership_id,
  keyword,
  round(prev_avg_pos::numeric,2) AS prev_pos,
  round(curr_avg_pos::numeric,2) AS curr_pos,
  round(prev_avg_pos - curr_avg_pos,2) AS improvement
FROM pairs
WHERE (prev_avg_pos - curr_avg_pos) >= 3
ORDER BY improvement DESC;


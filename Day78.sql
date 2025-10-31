/*
You are the BI Engineer for a digital agency that tracks organic performance using the raw_serp dataset.
Each row in the table represents a search result for a keyword in a region at a given date.
The marketing team wants to identify the most influential domains per region over the past 3 months — not just by rank, but by how consistently visible and engaging they are.
For each region, calculate the Domain Influence Index (DII) for all domains over the last 3 months, and find the top 5 domains per region based on DII.
*/

WITH base AS (
    SELECT
        region,
        domain,
        AVG(position) AS avg_position,
        STDDEV(position) AS position_volatility,
        SUM(clicks) AS total_clicks,
        SUM(impressions) AS total_impressions
    FROM raw_serp
    WHERE serp_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '3 months'
    GROUP BY region, domain
),

--  CTR (Engagement)
ctr_calc AS (
    SELECT
        region,
        domain,
        CASE WHEN SUM(total_impressions) = 0 THEN 0
             ELSE SUM(total_clicks)::float / SUM(total_impressions)::float
        END AS ctr
    FROM base
    GROUP BY region, domain
),

--  Stability (1 / (1 + STDDEV))
stability_calc AS (
    SELECT
        region,
        domain,
        (1 / (1 + COALESCE(position_volatility, 0))) AS stability
    FROM base
),

-- Share of Voice (Impressions per region)
sov_calc AS (
    SELECT
        region,
        domain,
        SUM(total_impressions)::float / SUM(SUM(total_impressions)) OVER (PARTITION BY region) AS sov
    FROM base
    GROUP BY region, domain
),

--Combine all metrics and compute DII
domain_influence AS (
    SELECT
        c.region,
        c.domain,
        c.ctr,
        s.stability,
        v.sov,
        ROUND(0.5 * c.ctr + 0.3 * s.stability + 0.2 * v.sov, 4) AS DII
    FROM ctr_calc c
    JOIN stability_calc s ON c.region = s.region AND c.domain = s.domain
    JOIN sov_calc v ON c.region = v.region AND c.domain = v.domain
),

--  Rank top 5 domains per region
ranked_domains AS (
    SELECT
        region,
        domain,
        ctr,
        stability,
        sov,
        DII,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY DII DESC) AS rank_dii
    FROM domain_influence
)

SELECT
    region,
    domain,
    ROUND(ctr, 4) AS ctr,
    ROUND(stability, 4) AS stability,
    ROUND(sov, 4) AS sov,
    ROUND(DII, 4) AS DII
FROM ranked_domains
WHERE rank_dii <= 5
ORDER BY region, DII DESC;

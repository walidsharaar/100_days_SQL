/*
 Find the top 3 domains per region that have the lowest keyword ranking volatility (i.e., most stable rankings) during 3 months.
Only consider keywords that appeared at least twice in those 3 months.
Volatility per keyword = standard deviation of position.
Domain volatility = average of volatility across its keywords.
*/

WITH keyword_volatility AS (
    SELECT
        region,
        domain,
        keyword,
        STDDEV(position) AS keyword_volatility,
        AVG(position) AS avg_keyword_position,
        COUNT(DISTINCT serp_date) AS days_tracked
    FROM raw_serp
    GROUP BY region, domain, keyword
    HAVING COUNT(DISTINCT serp_date) >= 2
),

domain_stability AS (
    SELECT
        region,
        domain,
        AVG(keyword_volatility) AS avg_volatility,
        AVG(avg_keyword_position) AS avg_position,
        COUNT(DISTINCT keyword) AS keyword_count
    FROM keyword_volatility
    GROUP BY region, domain
),

ranked_domains AS (
    SELECT
        region,
        domain,
        avg_position,
        avg_volatility,
        keyword_count,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY avg_volatility ASC) AS rank_stability
    FROM domain_stability
)

SELECT
    region,
    domain,
    ROUND(avg_position, 2) AS avg_position,
    ROUND(avg_volatility, 2) AS avg_volatility,
    keyword_count
FROM ranked_domains
WHERE rank_stability <= 3
ORDER BY region, avg_volatility ASC;

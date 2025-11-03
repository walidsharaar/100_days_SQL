
/*
You’re a Senior BI Engineer at HealthTrack Analytics.
Leadership wants to understand which departments outperform their hospital’s overall performance trend, after accounting for doctor workload.

This helps identify departments that are truly improving, not just because of a few lucky cases or small sample sizes.
*/

WITH doctor_monthly AS (
    SELECT
        hospital_id,
        department_id,
        doctor_id,
        DATE_TRUNC('month', visit_date) AS month,
        COUNT(*) AS total_visits,
        AVG(treatment_success::float) AS success_rate,
        AVG(patient_feedback) AS avg_feedback,
        ((AVG(treatment_success::float) * 0.7) + (AVG(patient_feedback) / 5 * 0.3)) AS performance_score
    FROM patient_visits
    GROUP BY hospital_id, department_id, doctor_id, DATE_TRUNC('month', visit_date)
),

dept_total_visits AS (
    SELECT
        hospital_id,
        department_id,
        month,
        SUM(total_visits) AS dept_visits
    FROM doctor_monthly
    GROUP BY hospital_id, department_id, month
),

doctor_weighted AS (
    SELECT
        d.hospital_id,
        d.department_id,
        d.doctor_id,
        d.month,
        d.performance_score,
        (d.total_visits * 1.0 / v.dept_visits) AS visit_weight,
        d.performance_score * (d.total_visits * 1.0 / v.dept_visits) AS weighted_score
    FROM doctor_monthly d
    JOIN dept_total_visits v 
      ON d.hospital_id = v.hospital_id
     AND d.department_id = v.department_id
     AND d.month = v.month
),

department_monthly AS (
    SELECT
        hospital_id,
        department_id,
        month,
        SUM(weighted_score) AS dept_perf
    FROM doctor_weighted
    GROUP BY hospital_id, department_id, month
),

trend_calc AS (
    SELECT
        hospital_id,
        department_id,
        month,
        dept_perf,
        dept_perf - LAG(dept_perf) OVER (
            PARTITION BY hospital_id, department_id
            ORDER BY month
        ) AS month_over_month_change
    FROM department_monthly
),

dept_avg_trend AS (
    SELECT
        hospital_id,
        department_id,
        AVG(CASE WHEN month_over_month_change > 0 THEN month_over_month_change ELSE 0 END) AS avg_positive_trend
    FROM trend_calc
    GROUP BY hospital_id, department_id
),

hospital_avg_trend AS (
    SELECT
        hospital_id,
        AVG(avg_positive_trend) AS hospital_trend
    FROM dept_avg_trend
    GROUP BY hospital_id
)

SELECT
    d.hospital_id,
    d.department_id,
    d.avg_positive_trend AS dept_trend,
    h.hospital_trend,
    ROUND(d.avg_positive_trend - h.hospital_trend, 4) AS trend_diff
FROM dept_avg_trend d
JOIN hospital_avg_trend h
  ON d.hospital_id = h.hospital_id
WHERE d.avg_positive_trend > h.hospital_trend
ORDER BY trend_diff DESC;

---|Alternative

-- Step 1: Doctor performance per month
WITH doctor_monthly AS (
    SELECT
        hospital_id,
        department_id,
        doctor_id,
        DATE_TRUNC('month', visit_date) AS month,
        COUNT(*) AS total_visits,
        AVG(treatment_success::float) AS success_rate,
        AVG(patient_feedback) AS avg_feedback,
        ((AVG(treatment_success::float) * 0.7) + (AVG(patient_feedback) / 5 * 0.3)) AS performance_score
    FROM patient_visits
    GROUP BY hospital_id, department_id, doctor_id, DATE_TRUNC('month', visit_date)
),

-- Step 2: Department total visits per month
dept_total_visits AS (
    SELECT
        hospital_id,
        department_id,
        month,
        SUM(total_visits) AS dept_visits
    FROM doctor_monthly
    GROUP BY hospital_id, department_id, month
),

-- Step 3: Weighted doctor score
doctor_weighted AS (
    SELECT
        d.hospital_id,
        d.department_id,
        d.doctor_id,
        d.month,
        d.performance_score,
        (d.total_visits * 1.0 / v.dept_visits) AS visit_weight,
        d.performance_score * (d.total_visits * 1.0 / v.dept_visits) AS weighted_score
    FROM doctor_monthly d
    JOIN dept_total_visits v
      ON d.hospital_id = v.hospital_id
     AND d.department_id = v.department_id
     AND d.month = v.month
),

-- Step 4: Department monthly performance (aggregate doctor-level)
department_monthly AS (
    SELECT
        hospital_id,
        department_id,
        month,
        SUM(weighted_score) AS dept_perf
    FROM doctor_weighted
    GROUP BY hospital_id, department_id, month
),

-- Step 5: Self-join to find month-over-month change (simulate LAG)
month_comparison AS (
    SELECT
        cur.hospital_id,
        cur.department_id,
        cur.month,
        cur.dept_perf,
        prev.dept_perf AS prev_perf,
        (cur.dept_perf - prev.dept_perf) AS mom_change
    FROM department_monthly cur
    LEFT JOIN department_monthly prev
      ON cur.hospital_id = prev.hospital_id
     AND cur.department_id = prev.department_id
     AND prev.month = cur.month - INTERVAL '1 month'
),

-- Step 6: Average positive trends for each department
dept_avg_trend AS (
    SELECT
        hospital_id,
        department_id,
        AVG(CASE WHEN mom_change > 0 THEN mom_change ELSE 0 END) AS avg_positive_trend
    FROM month_comparison
    GROUP BY hospital_id, department_id
),

-- Step 7: Hospital-level trend average
hospital_avg_trend AS (
    SELECT
        hospital_id,
        AVG(avg_positive_trend) AS hospital_trend
    FROM dept_avg_trend
    GROUP BY hospital_id
)

-- Step 8: Compare departments vs hospital average
SELECT
    d.hospital_id,
    d.department_id,
    ROUND(d.avg_positive_trend, 4) AS dept_trend,
    ROUND(h.hospital_trend, 4) AS hospital_trend,
    ROUND(d.avg_positive_trend - h.hospital_trend, 4) AS trend_diff
FROM dept_avg_trend d
JOIN hospital_avg_trend h
  ON d.hospital_id = h.hospital_id
WHERE d.avg_positive_trend > h.hospital_trend
ORDER BY trend_diff DESC;


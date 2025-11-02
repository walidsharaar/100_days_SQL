/*
Find Top 3 departments (department_id) in each hospital that show the strongest month-over-month improvement trend in doctor performance.
*/


WITH doctor_monthly AS (
    SELECT
        hospital_id,
        department_id,
        doctor_id,
        date_trunc('month', visit_date) AS month,
        AVG(treatment_success::float) AS success_rate,
        AVG(patient_feedback) AS avg_feedback,
        ((AVG(treatment_success::float) * 0.7) + (AVG(patient_feedback) / 5 * 0.3)) AS performance_score
    FROM patient_visits
    GROUP BY hospital_id, department_id, doctor_id, date_trunc('month', visit_date)
),

department_monthly AS (
    SELECT
        hospital_id,
        department_id,
        month,
        AVG(performance_score) AS dept_perf
    FROM doctor_monthly
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

avg_trend AS (
    SELECT
        hospital_id,
        department_id,
        AVG(CASE WHEN month_over_month_change > 0 THEN month_over_month_change ELSE 0 END) AS avg_positive_trend
    FROM trend_calc
    GROUP BY hospital_id, department_id
)

SELECT 
    hospital_id,
    department_id,
    avg_positive_trend,
    RANK() OVER (PARTITION BY hospital_id ORDER BY avg_positive_trend DESC) AS dept_rank
FROM avg_trend
WHERE avg_positive_trend IS NOT NULL
QUALIFY dept_rank <= 3;


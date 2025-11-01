/*
Find the top 3 doctors (doctor_id) across all hospitals who meet the following conditions:

They have handled at least 30 patient visits.

Their average treatment success rate is above the hospital average.

Return:

doctor_id

hospital_id

total_patients

success_rate

avg_feedback

performance_score

rank (1 = highest performer)
*/


WITH doctor_stats AS (
    SELECT 
        hospital_id,
        doctor_id,
        COUNT(DISTINCT patient_id) AS total_patients,
        AVG(treatment_success::float) AS success_rate,
        AVG(patient_feedback) AS avg_feedback
    FROM patient_visits
    GROUP BY hospital_id, doctor_id
),
hospital_avg AS (
    SELECT 
        hospital_id,
        AVG(treatment_success::float) AS hospital_success_avg
    FROM patient_visits
    GROUP BY hospital_id
),
filtered_doctors AS (
    SELECT 
        d.*,
        h.hospital_success_avg,
        ((d.success_rate * 0.7) + (d.avg_feedback / 5 * 0.3)) AS performance_score
    FROM doctor_stats d
    JOIN hospital_avg h USING (hospital_id)
    WHERE d.total_patients >= 30
      AND d.success_rate > h.hospital_success_avg
      AND d.avg_feedback > 4.2
)
SELECT 
    doctor_id,
    hospital_id,
    total_patients,
    ROUND(success_rate, 3) AS success_rate,
    ROUND(avg_feedback, 2) AS avg_feedback,
    ROUND(performance_score, 3) AS performance_score,
    RANK() OVER (ORDER BY performance_score DESC) AS rank
FROM filtered_doctors
LIMIT 3;


--Alternative Solution without CTEs
SELECT 
    d.hospital_id,
    d.doctor_id,
    d.total_patients,
    d.success_rate,
    d.avg_feedback,
    ((d.success_rate * 0.7) + (d.avg_feedback / 5 * 0.3)) AS performance_score
FROM (
    SELECT 
        hospital_id,
        doctor_id,
        COUNT(DISTINCT patient_id) AS total_patients,
        AVG(treatment_success::float) AS success_rate,
        AVG(patient_feedback) AS avg_feedback
    FROM patient_visits
    GROUP BY hospital_id, doctor_id
) d
JOIN (
    SELECT hospital_id, AVG(treatment_success::float) AS hospital_success_avg
    FROM patient_visits
    GROUP BY hospital_id
) h
ON d.hospital_id = h.hospital_id
WHERE d.total_patients >= 30
  AND d.success_rate > h.hospital_success_avg
  AND d.avg_feedback > 4.2
ORDER BY performance_score DESC
LIMIT 3;

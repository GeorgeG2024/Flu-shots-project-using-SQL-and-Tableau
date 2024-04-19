/* Project objective
Create a flu shots dashboard for 2022 by completing the following.

1. Total % of patients getting flu shots stratified by 
	a. Age
	b. Race
	c. County (Using a Map)
	d. Overall
2. Running Total of Flu Shots over the course of 2022
3. Total number of flu shots given in 2022
4. A list of Patients that show whether or not they received the flu shots

Conditions: 

Focus only on "Active Patients at our hospital"
*/

WITH active_patients AS
(
	SELECT patient
	FROM encounters AS e
	JOIN patients AS pats
	ON e.patient = pats.id
	WHERE START BETWEEN '2020-01-01 00:00' AND '2022-12-31 23:59'
	AND pats.deathdate IS null
	AND EXTRACT(EPOCH FROM age ('2022-12-31',pats.birthdate)) /2592000 >=6
),

flu_shot_2022 as 
(
SELECT patient, MIN(date) AS initial_flu_shot_2022
FROM immunizations
WHERE code = '5302'
AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
GROUP BY patient
)

SELECT pats.birthdate,
       pats.race, 
	   pats.county, 
	   pats.id, 
	   pats.first, 
	   pats.last,
	   flu.initial_flu_shot_2022,
	   flu.patient,
	   extract(YEAR FROM age('2022-12-31', birthdate)) as age,
	   CASE 
	   WHEN flu.patient IS NOT null THEN 1
	   ELSE 0
	   END AS flu_shot_2022
FROM patients AS pats
LEFT JOIN flu_shot_2022 AS flu
ON pats.id = flu.patient
WHERE 1=1
AND pats.id IN (SELECT patient FROM active_patients)

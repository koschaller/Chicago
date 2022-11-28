/*


Data Exploration of the Chicago Census and Public Schools

Skills used: Create Table, Aggregate Functions, CTEs, Subqueries, CASE Statements 


*/

CREATE TABLE census
(
    community_area_number VARCHAR(2) PRIMARY KEY,
	community_area_name VARCHAR(55),
    housing_crowded DECIMAL(4,3),
	households_below_poverty DECIMAL(4,3),
	aged_16_unemployed DECIMAL(4,3),
    aged_25_without_hs_diploma DECIMAL(4,3),
	aged_under_18_or_over_64 DECIMAL(4,3),
	per_capita_income INT,
	hardship_index INT
);

CREATE TABLE schools
(
    school_id VARCHAR(6) PRIMARY KEY,
	name_of_school VARCHAR(255),
    school_type CHAR(2),
	address VARCHAR(255),
	city CHAR(7),
	state CHAR(2),
    zip_code INT,
	safety_score INT,
	avg_student_attendance DECIMAL(4,3),
	latitude DECIMAL(12,9),
	longitude DECIMAL(12,9),
	community_area_number VARCHAR(2),
	community_area_name VARCHAR(55)
);

CREATE TABLE networks
(
	school_id VARCHAR(6) PRIMARY KEY,
	network_manager VARCHAR(55),
	collaborative_name VARCHAR(55),
	track_schedule VARCHAR(55),
	community_area_number VARCHAR(2),
	community_area_name VARCHAR(55),
	ward INT
);



-- Average student attendence percentage for all Chicago public schools

SELECT AVG(avg_student_attendance)*100
FROM schools;

-- Average student attendace percentage for school types

SELECT school_type, AVG(avg_student_attendance)
FROM schools
GROUP BY school_type;

-- Average safety score for all Chicago public schools, school type

SELECT AVG(safety_Score)
FROM schools;

-- Count of schools following standard vs track e vs non-standard track schedule

SELECT track_schedule, COUNT(track_schedule)
FROM networks
GROUP BY track_schedule
ORDER BY COUNT(track_schedule) DESC;

-- Average student attendance percentage per community

SELECT community_area_name, ROUND(AVG(avg_student_attendance), 2)*100
FROM schools
GROUP BY community_area_name
ORDER BY AVG(avg_student_attendance) DESC;

-- Communities without a HS

SELECT community_area_name
FROM schools
WHERE NOT community_area_name IN (SELECT community_area_name
								 FROM schools
								 WHERE school_type = 'HS'
								 GROUP BY community_area_name)
GROUP BY community_area_name;

-- Percent difference (decrease) between ES and HS average attendance by community

WITH groups AS(
				SELECT community_area_name,
					   AVG(CASE WHEN school_type = 'HS' THEN avg_student_attendance END) AS HS,
					   AVG(CASE WHEN school_type = 'ES' THEN avg_student_attendance END) AS ES
				FROM schools
				GROUP BY community_area_name
)
SELECT community_area_name, ROUND(100*(ES-HS)/HS, 2) AS perdiff
FROM groups
GROUP BY community_area_name, 100*(ES-HS)/HS 
HAVING 100*(ES-HS)/HS IS NOT NULL
ORDER BY 100*(ES-HS)/HS DESC;

-- Count of schools located in areas where per capita income is less than Chicago average per capita income

SELECT COUNT(school_id)
FROM schools 
WHERE community_area_name IN (SELECT community_area_name
							  FROM census
							  WHERE per_capita_income < 28202)

-- Count of schools located in communtities where percent of households living in poverty is greater than percent of households living in poverty for all of Chicago

SELECT COUNT(school_id)
FROM schools 
WHERE community_area_name IN (SELECT community_area_name
							  FROM census
							  WHERE households_below_poverty > 0.197);
							  
SELECT c.per_pov, COUNT(s.school_id)
FROM schools s
LEFT JOIN (SELECT community_area_name, 
		   		  households_below_poverty, 
		  		  CASE
		  				WHEN households_below_poverty > '0.197' THEN 'Below'
		  				WHEN households_below_poverty = '0.197' THEN 'Average' 
		                WHEN households_below_poverty < '0.197' THEN 'Above'
		   				ELSE ''
		  	      END AS per_pov
		   FROM census
		  ) c
ON s.community_area_name = c.community_area_name
GROUP BY c.per_pov;

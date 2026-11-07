--USE PoliceData
-- Record Count

SELECT COUNT(*) 
FROM PoliceData;

-- Datatypes
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PoliceData';

-- check nulls

SELECT COUNT(*) AS total_nulls
FROM PoliceData 
WHERE search_type IS NULL;

-- remove the column that only contains nulls - county_name

ALTER TABLE PoliceData
DROP COLUMN county_name;

-- list the column names
--Method 1

SELECT TOP 0* 
FROM PoliceData;

--Method 2

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PoliceData'

-- Do women or men speed more often ?
  
SELECT 
    driver_gender, 
    COUNT(*)
FROM PoliceData
GROUP BY driver_gender
ORDER BY COUNT(*) DESC;

-- clearly men are speeding more often, lets replace the driver_gender blanks with some text

UPDATE PoliceData
SET driver_gender = 'Unknown'
WHERE driver_gender IS NULL;

--Lets find violations for each gender
  
SELECT 
    driver_gender, 
    violation_raw, 
    COUNT(*) as total_violations
FROM PoliceData
GROUP BY 
    violation_raw, 
    driver_gender
ORDER BY 
    driver_gender, 
    violation_raw;

--Does gender affect who gets searched during a stop?
  
SELECT driver_gender, 
    CASE WHEN search_conducted=0 THEN 'No' ELSE 'Yes' END AS search_conducted, 
    COUNT(*) as search_count
FROM PoliceData
GROUP BY 
    driver_gender, 
    search_conducted
ORDER BY 
    driver_gender, 
    search_conducted;

-- Men are searched relatively more often but then the break rules more often too

--query on types of searches and respective counts
  
SELECT 
    search_type, 
    COUNT(*) AS total
FROM PoliceData
GROUP BY search_type
ORDER BY COUNT(*) ASC;

-- replace search type null to unknown
  
Update PoliceData
set search_type = 'Unknown'
WHERE search_type IS NULL;

--During a search, how often is the driver frisked?
  
SELECT 
    search_type, 
    COUNT(*) AS total
FROM PoliceData
WHERE search_type LIKE '%[Ff]risk%'
GROUP BY search_type
ORDER BY COUNT(*) DESC;

--Which year had the least number of stops?

SELECT 
    YEAR(stop_date) AS 'year', 
    COUNT(*) AS total_Stops
FROM PoliceData
GROUP BY YEAR(stop_date)
ORDER BY COUNT(*) ASC;

--How does drug activity change by time of day?

SELECT 
    STR(Datepart(HOUR, stop_time))+':00' AS 'hour', 
    COUNT(*) as total_Stops
FROM PoliceData 
GROUP BY Datepart(HOUR, stop_time)
ORDER BY Datepart(HOUR, stop_time);

--Do most stops occur at night?
  
SELECT 
    STR(Datepart(HOUR, stop_time))+':00' AS 'hour', 
    COUNT(*) AS total_Stops
FROM PoliceData 
GROUP BY DATEPART(HOUR, stop_time)
ORDER BY COUNT(*) DESC;

-- Most stops occur at night around 10-11pm

--Find the bad data in the stop_duration column and fix it!
  
SELECT COUNT(*)
FROM PoliceData
WHERE stop_duration IS NULL;

-- we have 5333 null values in stop_duration column, lets fix it with duration = 0
--lets first check if any other bad data in the column

SELECT 
    stop_duration, 
    COUNT(*) AS cnt
FROM PoliceData
GROUP BY stop_duration;

-- 1, 2 data is also not in accordance with the column, lets make those null
  
UPDATE PoliceData
SET stop_duration = NULL
WHERE stop_duration IN ('1', '2');

-- now we have 5335 nulls in the data
  
UPDATE policeData
SET stop_duration = '0 Min'
WHERE stop_duration IS NULL;

--What is the mean stop_duration for each violation_raw? 
--we will need to convert stop_duration strings to numbers
  
WITH convertStopDuration AS (
	SELECT stop_duration,
	CASE 
		WHEN stop_duration='0 Min' THEN 0
		WHEN stop_duration='0-15 Min' THEN 10
		WHEN stop_duration='16-30 Min' THEN 25
		WHEN stop_duration='30+ Min' THEN 45
	END AS 'time',
	COUNT(*) AS total_stops
	FROM policeData 
	GROUP BY stop_duration
);

--adding a new column called stop_minutes in the table
  
ALTER TABLE policeData 
ADD stop_minutes int

UPDATE policeData
SET stop_minutes = (
	CASE 
		WHEN stop_duration='0 Min' THEN 0
		WHEN stop_duration='0-15 Min' THEN 10
		WHEN stop_duration='16-30 Min' THEN 25
		WHEN stop_duration='30+ Min' THEN 45
	END
);

SELECT * 
FROM convertStopDuration;
  
SELECT 
    stop_duration, 
    AVG(time*total_Stops) AS 'Avg_stop_time'
FROM convertStopDuration
GROUP BY stop_duration;

-- mean and count for each violation
  
SELECT 
    violation_raw, 
    COUNT(*) AS 'cnt', 
    AVG(stop_minutes) AS 'average'
FROM policeData
GROUP BY violation_raw
ORDER BY violation_raw;

--Compare the age distributions for each violation
  
SELECT 
    violation_raw, 
    driver_age, 
    COUNT(*) AS total_violations
FROM policeData
GROUP BY 
    violation_raw, 
    driver_age
ORDER BY COUNT(*) DESC;

-- since we have drivers of various different ages, the group by result is not very well readable
-- lets group drivers by age groups rather than individual age
-- add a new column for age group

ALTER TABLE policeData 
ADD age_group VARCHAR(20)
UPDATE policeData
SET age_group = (
	CASE 
    WHEN driver_age<18 THEN '18 below'
	  WHEN driver_age>=18 AND driver_age<25 THEN '18-25'
	  WHEN driver_age>=25 AND driver_age<60 THEN '25-60'
	  WHEN driver_age>=60 THEN '60+'
	  WHEN driver_age IS NULL THEN 'Unknown'
	END 
)

SELECT 
    violation_raw, 
    age_group, 
    COUNT(*) AS total_violations
FROM policeData
GROUP BY 
    age_group, 
    violation_raw
ORDER BY age_group;

SELECT * 
FROM policeData;

--create current driver age as curr_age from driver_age_raw (and call it curr_age)

ALTER TABLE policeData 
ADD curr_age int
UPDATE policeData 
SET curr_age = YEAR(GETDATE()) - driver_age_raw;

-- get count of =< 15 age and 90 and + age drivers
  
SELECT 
    driver_age, 
    violation_raw, 
    stop_duration, 
CASE WHEN search_conducted=0 THEN 'No' ELSE 'Yes' END AS search_conducted, stop_outcome
FROM policeData
WHERE driver_age<=15 
  OR driver_age>=90
ORDER BY driver_age;

-- the underage drivers were in most cases arrested

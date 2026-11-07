-- Data analysis/EDA on Kaggle Titanic dataset - https://www.kaggle.com/datasets/yasserh/titanic-dataset/data

SELECT * 
FROM Titanic;

USE Titanic;

-- show count of survived/non-survived

SELECT 
    CASE WHEN Survived=0 THEN 'No' ELSE 'Yes' 
    END AS Survived,
    COUNT(*) as 'count'
FROM Titanic
GROUP BY Survived;

-- show survival rate

WITH survivalCnt AS(
    SELECT
    CASE WHEN Survived=0 THEN 'No' ELSE 'Yes'
    END AS Survived,
    SUM(COUNT(*)) OVER(PARTITION BY Survived ) AS cnt
FROM Titanic
GROUP BY Survived
)
SELECT Survived, cnt,
    ROUND(cnt * 100 / (SELECT SUM(cnt) FROM survivalCnt), 2) AS "%"
FROM survivalCnt;

-- show male vs female count in the ship

SELECT Sex, COUNT(*) AS 'count'
FROM Titanic
GROUP BY Sex;

-- show sex wise survival count 

SELECT 
    Sex,
    CASE WHEN Survived=0 THEN 'No' ELSE 'Yes' 
    END AS Survived,
    COUNT(*) AS 'count'
FROM Titanic
GROUP BY 
    Survived, 
    Sex
ORDER BY 
    Sex, 
    Survived;

SELECT * from Titanic;

-- divide people in age group
-- 0-18, 19-30, 31-50, 51-80, 80+

ALTER TABLE Titanic 
ADD  ageGrp VARCHAR(10);

UPDATE Titanic 
SET ageGrp = (
	CASE
	WHEN age<=18 THEN '0-18'
	WHEN age>18 AND age<=30 THEN '19-30'
	WHEN age>30 AND age<=50 THEN '31-50'
	WHEN age>50 AND age<=80 THEN '51-80'
	WHEN age>80 THEN '80+'
	END 
);

-- now we can group by ageGrp and check survival counts
SELECT 
    Survived, 
    ageGrp, 
    COUNT(*) AS 'total'
FROM Titanic
GROUP BY 
    ageGrp, 
    Survived
ORDER BY 
    ageGrp, 
    Survived;

-- find how many passenger are on board without a ticket
  
SELECT COUNT(*)
FROM Titanic
WHERE Ticket IS NULL;
  
-- no passenger is travelling without a ticket

-- finding, max, min, average Fare
  
SELECT 
    ROUND(MAX(Fare), 2) AS max_Fare, 
    ROUND(MIN(Fare), 2) AS min_Fare, 
    ROUND(AVG(Fare), 2) AS avg_Fare
FROM Titanic;

--seems like some passengers paid no money for their ticket, find the count with 0 fare

SELECT COUNT(*)
FROM Titanic
WHERE Fare=0;

SELECT *
FROM Titanic
WHERE Fare = 0 
    AND cabin IS NOT NULL;

-- out of 15 passengers who paid nothing for the ticket, 3 even have their own cabin - strange

-- count of passenger with cabin

SELECT COUNT(*)
FROM Titanic
WHERE Cabin IS NOT NULL;

-- create a new column with family size of each passenger

ALTER TABLE Titanic 
ADD familySize int;

UPDATE Titanic 
SET familySize = SibSp+Parch+1;

-- grouping on family size

SELECT 
    familySize, 
    COUNT(*) AS total
FROM Titanic
GROUP BY familySize
ORDER BY familySize ASC;

-- most passengers were crusing alone

-- calculate percentage by familySize

WITH familySizeGrp AS(
    SELECT familySize, 
    COUNT(*) AS total
FROM Titanic
GROUP BY familySize
)
SELECT 
    familySize, 
    total, 
    ROUND(total*100/(SELECT SUM(total) 
    FROM familySizeGrp), 2) AS 'percentage'
FROM familySizeGrp
ORDER BY familySize ASC;

-- grouping passengers on class
  
SELECT 
    Pclass, 
    COUNT(*)
FROM Titanic 
GROUP BY Pclass;

-- adding  gender to the above grouping
  
SELECT 
    Pclass, 
    Sex, 
    COUNT(*) AS 'count'
FROM Titanic
GROUP BY 
    Pclass, 
    Sex
ORDER BY 
    Pclass, 
    Sex;

-- finding rolling fare price

SELECT 
    ROUND(Fare, 2) AS rounded_Fare,
    ROUND(SUM(Fare) OVER(ORDER BY PassengerId), 2) AS rolling_sum
FROM Titanic;

-- partition fare on age group and find top prices from each group
  
WITH ageFareRank AS (
	  SELECT
            ageGrp, 
            ROUND(fare, 0) AS fare_int,
	  DENSE_RANK() OVER(PARTITION BY ageGrp ORDER BY round(fare, 0)) AS rk
FROM Titanic;
  
	--where ageGrp is not null
)
SELECT 
    DISTINCT ageGrp,
    MIN(fare_int) OVER(PARTITION BY ageGrp) AS min_fare,
    MAX(fare_int) OVER(PARTITION BY ageGrp) AS max_Fare
  
--first_value(fare_int) over(order by ageGrp, fare_int, rk) as first_value
--LAST_VALUE(fare_int) over(partition by ageGrp order by rk) as last_Value
  
FROM ageFareRank
ORDER BY ageGrp ASC;

/*
	Port of Embarkation:C = Cherbourg, Q = Queenstown, S = Southampton
*/
-- group on port of embarkation and find respective counts
  
SELECT
    (CASE
	  WHEN Embarked='C' THEN 'Cherbourg'
	  WHEN Embarked='Q' THEN 'Queenstown'
	  WHEN Embarked='S' THEN 'Southampton'
	  ELSE 'Unknown'
	END) AS 'Port of Embarkment', 
  COUNT(*) AS 'No of passengers Embarked'
FROM Titanic
GROUP BY Embarked
ORDER BY 'Port of Embarkment' ASC;

-- count gender wise with port of embarkement
  
SELECT 
    (CASE
	  WHEN Embarked='C' THEN 'Cherbourg'
	  WHEN Embarked='Q' THEN 'Queenstown'
	  WHEN Embarked='S' THEN 'Southampton'
	  ELSE 'Unknown'
	END) AS 'Port of Embarkment',  
  Sex,
  COUNT(*) AS 'No of passengers Embarked'
FROM Titanic
GROUP BY 
    Embarked, 
    Sex
ORDER BY 
    'Port of Embarkment' ASC, 
    Sex;

SELECT * 
FROM Titanic;

-- lets find if we have any passenger called 'Rose' or 'Jack'
  
SELECT 
    Name, 
    Sex,  
    Age
FROM Titanic
WHERE name LIKE '%[Rr]ose%' 
  OR name LIKE '%[Jj]ack%';

-- I don't think we have who we were looking for

-- that is the end of data analysis/EDA on Titanic dataset with SQL ---

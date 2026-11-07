SELECT * 
FROM FIFA22_Matches;

-- find the number of distinct teams playing in FIFA 22

SELECT 
		COUNT(*) AS Total_Teams
FROM (
	SELECT DISTINCT team1 
	FROM FIFA22_Matches
	
UNION
	
	SELECT DISTINCT team2 
	FROM FIFA22_Matches)a;

-- find total matches

SELECT 
		COUNT(*) AS Total_Matches 
FROM FIFA22_Matches;

-- find total number of goals

SELECT 
		SUM(number_of_goals_team1) + SUM(number_of_goals_team2) AS Total_tournament_goals
FROM FIFA22_Matches;

-- find total number of red cards in the fifa 22
	
SELECT 
	SUM(red_cards_team1) + SUM(red_cards_team2) AS Total_Red_cards
FROM FIFA22_Matches;

-- find total yellow cards in fifa 22
	
SELECT 
	SUM(yellow_cards_team1) + SUM(yellow_cards_team2) AS Total_Yellow_cards
FROM FIFA22_Matches;

-- fouls committed by top 10 teams

SELECT 
		top 10 team, 
		SUM(fouls) AS total_fouls
FROM (
	SELECT 
		team1 AS team, 
		fouls_against_team1 AS fouls 
	FROM FIFA22_Matches
	
UNION ALL
	SELECT 
		team2 AS team , 
		fouls_against_team2 AS fouls 
	FROM FIFA22_Matches)a
GROUP BY team
ORDER BY total_fouls DESC;

-- possession values have '%' towards the end we need to trim the special character
	
UPDATE FIFA22_Matches
SET possession_team1 = TRIM('%' FROM possession_team1);

UPDATE FIFA22_Matches
SET possession_team2 = TRIM('%' FROM possession_team2);

UPDATE FIFA22_Matches
SET possession_in_contest = TRIM('%' FROM possession_in_contest);

-- Identify the Team with the Highest Average Possession
	
SELECT 
		team, 
		AVG(CAST(possesion AS int)) AS avg_possesion
FROM (
		SELECT 
			team1 AS team, 
			possession_team1 AS possesion 
		FROM FIFA22_Matches
	
UNION ALL
	
SELECT 
		team2 AS team, 
		possession_team2 AS possesion 
FROM FIFA22_Matches) a
GROUP BY team
ORDER BY  avg_possesion DESC;
	
-- spain has the highest average possession of any team

SELECT * 
FROM FIFA22_Matches;

-- Order teams by possession in contest
	
SELECT 
		team, 
		AVG(CAST(possesion AS int)) AS avg_possesion_in_contest
FROM (
	SELECT 
		team1 AS team, 
		possession_in_contest AS possesion 
	FROM FIFA22_Matches
	
UNION ALL
	
SELECT 
	team2 AS team, 
	possession_in_contest AS possesion 
FROM FIFA22_Matches) a
GROUP BY  team
ORDER BY  avg_possesion_in_contest DESC;

-- Team with best goal conversion rate
	
SELECT 
		team, 
		goals, 
		attempts, 
		CAST((100*goals)/attempts AS varchar) + '%' AS conversion_rate
FROM (

	SELECT 
		team, 
		SUM(goals) AS goals, 
		SUM(attempts) AS attempts
	
FROM (
	SELECT 
		team1 AS team, 
		number_of_goals_team1 AS goals, 
		on_target_attempts_team1 AS attempts 
	FROM FIFA22_Matches
	
UNION ALL
	
	SELECT 
		team2 AS team, 
		number_of_goals_team2 AS goals,  
		on_target_attempts_team2 as attempts 
	FROM FIFA22_Matches) a
	
GROUP BY team) b
ORDER BY 
		(100*goals)/attempts DESC;

SELECT * FROM FIFA22_Matches;

-- goal distribution inside and outside the box
	
SELECT 
		team, 
		SUM(inside_goals) AS total_inside_goals, 
		SUM(outside_goals) AS total_outside_goals
FROM (
	SELECT 
		team1 AS team, 
		goal_inside_the_penalty_area_team1 AS inside_goals, 
		goal_outside_the_penalty_area_team1 AS outside_goals 
	FROM FIFA22_Matches

UNION ALL
	
	SELECT
 		team2 AS team, 
		goal_inside_the_penalty_area_team2 AS inside_goals, 
		goal_outside_the_penalty_area_team2 AS outside_goals 
	FROM FIFA22_Matches) a
GROUP BY team
ORDER BY 
		SUM(inside_goals) + SUM(outside_goals) DESC;

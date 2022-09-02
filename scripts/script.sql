-- 1. What range of years for baseball games played does the provided database cover?

SELECT MAX(yearid) as maxyear,
       MIN(yearid) as minyear
FROM teams;

-- ANSWER -- 1871 through 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

-- people.height, people.namegiven, apperences.g_all, appearances.teamid, join on playerid

SELECT p.height, 
       p.namegiven,
       p.namelast,
       a.g_all,
       a.teamid
FROM people as p
JOIN appearances as a
    ON p.playerid = a.playerid
WHERE p.height IS NOT null
GROUP BY 1,2,3,4,5
ORDER BY p.height
LIMIT 1;

-- ANSWER -- 43	 "Edward Carl"	1 Game	"SLA" St. Louis Browns

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- collegeplaying.schoolid, people.namefirst, people.namelast, salaries.salary JOIN all on playerid

SELECT c.schoolid,
       p.namefirst,
       p.namelast, 
       CAST(CAST(SUM(DISTINCT(s.salary)) AS NUMERIC) AS MONEY)
FROM people as p
JOIN salaries as s
     ON p.playerid = s.playerid
JOIN collegeplaying as c
     ON p.playerid = c.playerid
WHERE schoolid = 'vandy' 
      AND p.namelast = 'Price'
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- ANSWER "vandy" "David" "Price"	"$81,851,296.00"

SELECT p.namefirst,
       p.namelast,
       CAST(CAST(SUM(s.salary) AS NUMERIC) AS MONEY)
FROM people as p
    JOIN salaries as s
        ON p.playerid = s.playerid
WHERE namelast = 'Price' 
      AND namefirst = 'David'
GROUP BY 1,2
ORDER BY 3 DESC;

-- -- 4. Using the fielding table, group players into three groups based on their position: 
--       label players with position OF as "Outfield", 
--       those with position "SS", "1B", "2B", and "3B" as "Infield"
--       those with position "P" or "C" as "Battery". 
--       Determine the number of putouts made by each of these three groups in 2016.

-- fielding.pos, fielding.po

SELECT SUM(po),    
       CASE 
           WHEN LOWER(pos) = 'of' THEN 'Outfield'
           WHEN LOWER(pos) IN ('p', 'c') THEN 'Battery'
           ELSE 'Infield' 
            END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY 2
ORDER BY 1 DESC;

-- ANSWER
-- 41424	"battery"
-- 29560	"outfield"
-- 58934	"infield"


-- 5. Find the average number of strikeouts (by batters) per game by decade since 1920. 
--    Round the numbers you report to 2 decimal places. 
--    Do the same for home runs per game. 
--    Do you see any trends?

Select CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	        WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	        WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	        WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	        WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	        WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	        WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	        WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	        WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	        WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
	            End As decade,
            ROUND(CAST(SUM(so) AS DECIMAL)/CAST(SUM(g) AS DECIMAL), 2) AS avg_strikeouts,
            ROUND(CAST(SUM(hr) AS DECIMAL)/CAST(SUM(g) AS DECIMAL), 2) AS avg_homeruns
FROM teams
Where yearid >= 1920
GROUP BY 1
ORDER BY 1;

SELECT teamid, so, yearid
FROM teams
WHERE yearid = '1880'
GROUP BY 1, 2, 3
ORDER BY yearid;

-- ANSWER
-- YEAR    SO      HR
-- "1920s"	2.81	0.40
-- "1930s"	3.32	0.55
-- "1940s"	3.55	0.52
-- "1950s"	4.40	0.84
-- "1960s"	5.72	0.82
-- "1970s"	5.14	0.75
-- "1980s"	5.36	0.81
-- "1990s"	6.15	0.96
-- "2000s"	6.56	1.07
-- "2010s"	7.52	0.98
-- Sterioids starting in the 90's. Crack down starting in the 00's.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

-- batting.playerid, batting.SB(stolen bases), batting.CS(caught stealing), batting.yearid, people.namefirst, people.namelast

-- Main code

SELECT b.yearid, 
       b.playerid,
       CONCAT(p.namefirst, ' ', p.namelast) AS name,
       b.sb, 
       b.cs, 
       ROUND(b.sb/(b.sb+b.cs)::DECIMAL, 2) AS steal_rate
FROM batting as b
JOIN people as p
    USING(playerid)
WHERE b.yearid = '2016' AND b.sb + b.cs >= 20
GROUP BY 1, 2, 3, 4, 5
ORDER BY 6 DESC;

--Clean code

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS name,
       ROUND(b.sb/(b.sb+b.cs)::DECIMAL, 2) AS steal_rate
FROM batting as b
JOIN people as p
    USING(playerid)
WHERE b.yearid = '2016' AND b.sb + b.cs >= 20
GROUP BY 1, 2
ORDER BY 2 DESC;

-- ANSWER "Chris Owings" 91%

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--     What is the smallest number of wins for a team that did win the world series? 
--     Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--     Then redo your query, excluding the problem year. 
--     How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--     What percentage of the time?

-- teams.w(wins), teams.wcwin(Y or N), teamid
-- 1981, 2011 strike

SELECT t.teamid, 
       t.w as Total_wins, 
FROM teams as t
WHERE yearid >= 1970 
      AND yearid <= 2016
      AND t.WSWin = 'N'
GROUP BY 1, 2
ORDER BY 2 DESC;

-- "SEA"	116

-- **Come back and join to show name** --

SELECT t.yearid, 
       t.teamid, 
       t.w as Total_wins,
       wswin
FROM teams as t
WHERE t.yearid >= 1970 
      AND t.WSWin = 'Y'
      GROUP BY 1,2,3,4
ORDER BY 3;

-- 1981	"LAN" 63 "Y" Strike year

--

SELECT t.yearid, t.teamid, t.w as Total_wins,wswin
FROM teams as t
WHERE t.yearid >= 1970 
      AND t.WSWin = 'Y'
      AND teamid <> 'LAN'
GROUP BY 1,2,3,4
ORDER BY 3;

-- 2006	"SLN"	83	"Y"

-- World series winner win total
SELECT teams.yearid, MAX(w) AS most_w
     FROM teams
     WHERE teams.yearid >= 1970
     GROUP BY teams.yearid
     ORDER BY teams.yearid ASC
-- 

-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 

-- teams.w(wins), teams.wcwin(Y or N), teamid

SELECT t.teamid, 
       t.w as Total_wins
FROM teams as t
WHERE yearid >= 1970 
      AND yearid <= 2016
      AND t.WSWin = 'Y'
GROUP BY 1, 2
ORDER BY 2 DESC;

-- 

WITH maxwinsperyear AS
                   (SELECT yearid,
					       MAX(w) as max_wins
					FROM teams as t
					WHERE yearid >= 1970
					GROUP BY 1
					ORDER BY 1 DESC)
SELECT CONCAT((ROUND((COUNT(t.yearid)::decimal)/46, 2)*100), '%') as percent_wins
FROM teams as t
    LEFT JOIN maxwinsperyear AS m
    USING (yearid)
WHERE t.w = m.max_wins
    AND t.wswin = 'Y';
      
-- ANSWER 26 percent


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- homegames.attendance, homegames.team, homegames.park, homegames.games

SELECT games, attendance
FROM homegames
WHERE year = 2016;

SELECT park, team, attendance/games AS avg_atten
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY 3 DESC
LIMIT 5;

--

SELECT p.park_name, h.team, h.attendance/h.games AS avg_atten
FROM homegames as h
JOIN parks as p
    ON h.park = p.park
WHERE year = 2016 AND games >= 10
ORDER BY 3 DESC
LIMIT 5;

-- ANSWER MOST
-- "Dodger Stadium"	    "LAN"	45719
-- "Busch Stadium III"	"SLN"	42524
-- "Rogers Centre"	    "TOR"	41877
-- "AT&T Park"	        "SFN"	41546
-- "Wrigley Field"	    "CHN"	39906

SELECT p.park_name, h.team, h.attendance/h.games AS avg_atten
FROM homegames as h
JOIN parks as p
    ON h.park = p.park
WHERE year = 2016 AND games >= 10
ORDER BY 3
LIMIT 5;

-- ANSWER - LEAST
-- "Tropicana Field"	                "TBA"	15878
-- "Oakland-Alameda County Coliseum"	"OAK"	18784
-- "Progressive Field"	                "CLE"	19650
-- "Marlins Park"	                    "MIA"	21405
-- "U.S. Cellular Field"	            "CHA"	21559

-- IF TIME ALLOWS
-- JOIN ONTO TEAMS TO GET FULL TEAM NAME.

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- awardsmanager.awardid, awardsmanager.playerid, awardsmanger.league, people.namefirst, people.namelast, teams.name
-- join awardsmanagers to people on playerid, join awardsmanager to team on yearid.
-- CTE to get a list of names that have one both.

SELECT * 
FROM awardsmanagers
WHERE LOWER(awardid) = LOWER('tsn manager of the year')

SELECT * 
FROM people
WHERE playerid = 'johnsda02';

-- List of names who have won both.
/* You have the names. */
WITH nlwinners AS
                   (SELECT playerid, lgid, awardid, yearid 
                   FROM awardsmanagers
                   WHERE LOWER(awardid) = LOWER('tsn manager of the year')
                   AND LOWER(lgid) = LOWER('NL')),
     alwinners AS
                   (SELECT playerid, lgid, awardid, yearid
                   FROM awardsmanagers
                   WHERE LOWER(awardid) = LOWER('tsn manager of the year')
                   AND LOWER(lgid) = LOWER('AL'))
SELECT DISTINCT(p.namefirst, p.namelast)
FROM nlwinners AS n
JOIN alwinners AS a
    ON n.playerid = a.playerid
JOIN people as p
    ON n.playerid = p.playerid
JOIN teams as t
    ON n.lgid = t.lgid
JOIN awardsmanagers as w
    ON n.playerid = w.playerid
WHERE LOWER(w.awardid) = LOWER('tsn managEr of the year')
    OR LOWER(w.awardid) = LOWER('tsn manager of the year')
    
-- ANSWER "(Davey,Johnson)"
--        "(Jim,Leyland)"

-- KM

WITH subq1 as (SELECT playerid, awardid, COUNT(DISTINCT lgid) as lg_count
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('NL', 'AL')
GROUP BY playerid, awardid
HAVING COUNT(DISTINCT lgid) = 2),

subq2 as (SELECT s1.playerid, s1.awardid, lg_count, yearid, lgid
FROM subq1 as s1
INNER JOIN awardsmanagers as am
ON s1.playerid = am.playerid AND s1.awardid = am.awardid)

SELECT s2.yearid, CONCAT(namefirst, ' ', namelast) as full_name, name, s2.lgid
FROM subq2 as s2
INNER JOIN people as p
ON s2.playerid = p.playerid
INNER JOIN managers as m
ON s2.yearid = m.yearid AND s2.lgid = m.lgid AND s2.playerid = m.playerid
INNER JOIN teams as t
ON m.yearid = t.yearid AND m.teamid = t.teamid AND m.lgid = t.lgid
ORDER BY full_name

--

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- batting.hr, batting.yearid, people.namnfirst, people.namelast

-- Display if the max home runs they have hit is in the year 2016
-- Now I need to only display the "Y" in the final
-- Then link out with first and last name. 
-- 264 total currently

WITH maxhomeruns AS
                (SELECT playerid, 
                        yearid, 
                        hr
                 FROM batting
                 WHERE yearid = '2016' 
                 AND hr > '0'),
	 max_in_2016 AS
			    (SELECT playerid,
						yearid,
						MAX(hr) AS max_hr 
			     FROM batting
				 WHERE hr > '0'
				 GROUP BY 1,2),
     total_years AS 
                (SELECT playerid, 
                 COUNT(yearid) AS played
                 FROM batting
                 GROUP BY playerid)

SELECT DISTINCT(m.playerid), CONCAT(namefirst, ' ', namelast), m.hr AS max2016, MAX(b.hr) AS careerhigh, m.yearid, max_hr,
	   CASE WHEN m.hr >= MAX(b.hr) 
            THEN 'Y'
	   ELSE 'N' 
	   END AS max_in_2016
FROM maxhomeruns as m
JOIN people as p
    ON p.playerid = m.playerid
JOIN batting as b
    ON b.playerid = p.playerid
JOIN max_in_2016 as ma
	ON m.playerid = ma.playerid
JOIN total_years as ty
    ON m.playerid = ty.playerid
WHERE max_hr = b.hr AND played >= 10
GROUP BY 1,2,3,5,6
ORDER BY max_in_2016 DESC, max_hr DESC;

-- ANSWER 
"Nelson Cruz"	    43
"Edwin Encarnacion"	42
"Nelson Cruz"	    43
"Robinson Cano"	    39
"Edwin Encarnacion"	42
"Miguel Cabrera"	38
"Chris Davis"	    38
"David Ortiz"	    38

-- JM

WITH max_homers AS 
               (SELECT
                    playerid,
                    MAX(hr) AS career_highest
                FROM batting
                GROUP BY playerid
                ORDER BY career_highest DESC)

SELECT
    p.namelast || ', ' || p.namefirst AS name,
    SUM(hr) AS homeruns
FROM batting AS b
LEFT JOIN people AS p
    ON b.playerid = p.playerid
JOIN max_homers AS m
    ON b.playerid = m.playerid
WHERE hr >= 1
    AND yearid = 2016
    AND debut :: DATE <= '2006-12-31'
    AND b.hr = m.career_highest
GROUP BY name
ORDER BY homeruns DESC;


--
-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

people to salaries to team, playerid = playerid , teamid = teamid

--Standardized salary
SELECT t.name, 
       t.yearid,
       t.w,
       (SUM(DISTINCT(salary))::DECIMAL)::MONEY,
       t.w/(SUM(DISTINCT(salary))::DECIMAL)
FROM people as p
JOIN salaries as s
    ON p.playerid = s.playerid
JOIN teams as t
    ON s.teamid = t.teamid
WHERE t.yearid >= '2000'
GROUP BY 1, 2, 3 
ORDER BY 4 DESC;




-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
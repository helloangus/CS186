-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
-- What is the highest era (earned run average) recorded in baseball history?
CREATE VIEW q0(era)
AS
 SELECT MAX(era)
 FROM pitching;
;

-- Question 1i
/*
In the people table, find the namefirst, namelast and birthyear for all players with weight greater than 300 pounds.
*/
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
/* 
Find the namefirst, namelast and birthyear of all players whose namefirst field contains a space. 
Order the results by namefirst, breaking ties with namelast both in ascending order.
*/
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast;
;

-- Question 1iii
/*
From the people table, group together players with the same birthyear, 
and report the birthyear, average height, and number of players for each birthyear. 
Order the results by birthyear in ascending order.
*/

CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear;
;

-- Question 1iv
/*
Following the results of part iii, 
now only include groups with an average height > 70. 
Again order the results by birthyear in ascending order.
*/
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p, halloffame h
  WHERE p.playerid = h.playerid AND h.inducted = 'Y'
  ORDER BY yearid DESC, p.playerid;
;

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  WITH CAcollege(playerid, schoolid) AS
    (SELECT c.playerid, c.schoolid 
    FROM collegeplaying c INNER JOIN schools s
    ON c.schoolid = s.schoolid
    WHERE s.schoolState = 'CA')

  SELECT namefirst, namelast, q.playerid, schoolid, yearid
  FROM q2i q INNER JOIN CAcollege c
  ON q.playerid = c.playerid
  ORDER BY yearid DESC, schoolid, q.playerid;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  WITH slg(playerid, yearid, AB, slgval) AS
  (
    SELECT playerid, yearid, AB, (H + H2B + 2*H3B + 3*HR + 0.0)/(AB+0.0)
    FROM batting
  )

  SELECT p.playerID, p.namefirst, p.namelast, s.yearid, s.slgval
  FROM people p INNER JOIN slg s
  ON p.playerid = s.playerid
  WHERE s.AB > 50
  ORDER BY s.slgval DESC, s.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH lslg(playerid, lslgval)
  AS 
    (
    SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0)/(SUM(AB) + 0.0)
    FROM batting
    GROUP BY playerid
    HAVING SUM(AB) > 50
    )

  SELECT p.playerid, p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  ORDER BY l.lslgval DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS

  WITH lslg(playerid, lslgval)
  AS 
    (
    SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0)/(SUM(AB) + 0.0)
    FROM batting
    GROUP BY playerid
    HAVING SUM(AB) > 50
    )

  SELECT p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  WHERE l.lslgval >
    (
      SELECT lslgval 
      FROM lslg 
      WHERE playerid = 'mayswi01'
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), avg(salary)
  FROM salaries s
  GROUP BY yearid
  ORDER BY yearid
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH 
  bins_statistics(binstart, binend, width) AS 
    (
    SELECT MIN(salary), MAX(salary), CAST (((MAX(salary) - MIN(salary))/10) AS INT)
    FROM salaries
    ),

  bins(binid, binstart, width) AS
    (
    SELECT CAST ((salary/width) AS INT), binstart, width
    FROM salaries, bins_statistics
    WHERE yearid = 2016
    )

  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH 
  salary_statistics(yearId, minSa, maxSa, avgSa) AS
  (
    SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
    FROM salaries
    GROUP BY yearID
  )

  SELECT s1.yearID, s1.minSa - s2.minSa, s1.maxSa - s2.maxSa, s1.avgSa - s2.avgSa
  FROM salary_statistics s1 INNER JOIN salary_statistics s2
  ON s1.yearID - 1 = s2.yearID
  ORDER BY s1.yearID
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH 
  maxId(playerID, salary, yearID) AS
  (
    SELECT playerID, salary, yearID
        FROM salaries
        WHERE (yearID = 2000 AND salary = 
            (SELECT MAX(salary)
              FROM salaries
              WHERE yearID = 2000
            ))
          OR
          (yearID = 2001 AND salary =
            (SELECT MAX(salary)
              FROM salaries
              WHERE yearID = 2001
            ))
  )

  SELECT p.playerID, p.nameFirst, p.nameLast, m.salary, m.yearID
  FROM people p INNER JOIN maxId m
  ON p.playerID = m.playerID
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID, MAX(s.salary) - MIN(s.salary)
  FROM allstarfull a INNER JOIN salaries s
  ON a.playerID = s.playerID AND a.yearID = s.yearID
  WHERE s.yearID = 2016
  GROUP BY a.teamID
;


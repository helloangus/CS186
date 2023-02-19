SELECT a.teamID, MAX(s.salary) - MIN(s.salary)
FROM allstarfull a INNER JOIN salaries s
ON a.playerID = s.playerID AND a.yearID = s.yearID
WHERE s.yearID = 2016
GROUP BY a.teamID
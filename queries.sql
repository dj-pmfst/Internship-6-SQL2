SELECT * FROM Tournaments;

SELECT * FROM Tournament_Teams WHERE tournament_id = 2;

SELECT * FROM Players WHERE team_id = 1;

SELECT * FROM Matches WHERE team_id = 2;

SELECT * FROM Matches WHERE team_home = 45;

SELECT 
    me.event_id,
    me.type,
    p.name,
    p.surname,
    me.minute,
    me.match_id
FROM Match_Events me
JOIN Players p ON me.player_id = p.player_id
WHERE match_id = 432;

SELECT 
    p.name,
    p.surname,
    p.team_id,
    me.match_id,
    me.minute,
    me.type
FROM Match_Events me 
JOIN Players p ON me.player_id = p.player_id
JOIN Matches m ON me.match_id = m.match_id
WHERE m.tournament_id = 39 
  AND (me.type = 'red card' OR me.type = 'yellow card');

SELECT 
    p.name,
    p.surname,
    t.name AS team_name,
    COUNT(*) AS goals
FROM Match_Events me 
JOIN Players p ON me.player_id = p.player_id
JOIN Matches m ON me.match_id = m.match_id
JOIN Teams t ON p.team_id = t.team_id
WHERE m.tournament_id = 49 
  AND me.type = 'goal' 
  AND p.role = 'forward'
GROUP BY p.player_id, p.name, p.surname, t.name
ORDER BY goals DESC;

SELECT 
	t.name AS team,
	tt.points, 
	tt.phase_reached,
	tt.final_position
FROM Tournament_Teams tt 
JOIN Teams t ON tt.team_id = t.team_id
WHERE tt.tournament_id = 49;

SELECT 
	t.name,
	t.year,
	m.match_id AS match,
	tm.name AS winner
FROM Tournaments t 
JOIN Tournament_Teams tt ON t.tournament_id = tt.tournament_id
JOIN Teams tm ON tt.team_id = tm.team_id
JOIN Matches m ON t.tournament_id = m.tournament_id
WHERE tt.phase_reached = 'finals';

SELECT 
    phase,
    COUNT(*) AS match_count
FROM Matches
GROUP BY phase;

SELECT 
	th.name AS team_home,
	ta.name AS team_away,
	m.phase,
	m.home_score,
	m.away_score
FROM Matches m
JOIN Teams th ON m.team_home = th.team_id
JOIN Teams ta ON m.team_away = ta.team_id
WHERE m.date = '11-08-2022'; 

SELECT 
	p.name,
	p.surname,
	COUNT(*) AS goals
FROM Match_Events me 
JOIN Players p ON me.player_id = p.player_id
JOIN Matches m ON me.match_id = m.match_id
WHERE m.tournament_id = 49 
GROUP BY p.player_id, p.name, p.surname
ORDER BY goals DESC; 

SELECT 
	t.name,
	t.year,
	tt.final_position
FROM Tournament_Teams tt 
JOIN Tournaments t ON tt.tournament_id = t.tournament_id
WHERE t.team_id = 7;

SELECT 
	t.name, 
	t.year,
	tm.name AS winner 
FROM Tournaments t 
JOIN Teams tm ON t.winner = tm.team_id
WHERE t.status = 'finished';

SELECT 
    t.name,
    t.year,
    COUNT(DISTINCT tt.team_id) AS teams,
    COUNT(DISTINCT p.player_id) AS players
FROM Tournaments t
LEFT JOIN Tournament_Teams tt ON t.tournament_id = tt.tournament_id
LEFT JOIN Players p ON tt.team_id = p.team_id
GROUP BY t.tournament_id, t.name, t.year
ORDER BY t.year ASC;

SELECT 
	t.name AS team_name,
    p.name,
    p.surname,  
    COUNT(*) AS goals
FROM Match_Events me 
JOIN Players p ON me.player_id = p.player_id
JOIN Matches m ON me.match_id = m.match_id
JOIN Teams t ON p.team_id = t.team_id
WHERE me.type = 'goal' 
  AND p.role = 'forward'
GROUP BY p.player_id, p.name, p.surname, t.name
ORDER BY goals DESC;

SELECT 
	r.name,
	r.surname,
	th.name AS team_home,
	ta.name AS team_away,
	m.phase
FROM Matches m
JOIN Referees r ON m.referee_id = r.referee_id
JOIN Teams th ON m.team_home = th.team_id
JOIN Teams ta ON m.team_away = ta.team_id
WHERE r.referee_id = 20;
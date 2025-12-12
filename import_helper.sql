ALTER TABLE Teams DISABLE TRIGGER ALL;
ALTER TABLE Referees DISABLE TRIGGER ALL;
ALTER TABLE Players DISABLE TRIGGER ALL;
ALTER TABLE Tournaments DISABLE TRIGGER ALL;
ALTER TABLE Matches DISABLE TRIGGER ALL;
ALTER TABLE Match_Events DISABLE TRIGGER ALL;
ALTER TABLE Tournament_Teams DISABLE TRIGGER ALL;
ALTER TABLE tournament_teams
DROP CONSTRAINT tournament_teams_tournament_id_team_id_key;

--import seed fileova
  --redoslijed:
    -- teams.sql
    -- referees.sql
    -- players.sql 
    -- tournaments.sql
    -- matches.sql
    -- match_events.sql
    -- tournament_teams.sql

DELETE FROM Referees 
WHERE dob >= CURRENT_DATE - INTERVAL '18 years';

DELETE FROM Players 
WHERE dob >= CURRENT_DATE - INTERVAL '18 years';

DELETE FROM Matches 
WHERE team_home = team_away;

DELETE FROM tournament_teams a
USING tournament_teams b
WHERE a.ctid < b.ctid
  AND a.tournament_id = b.tournament_id
  AND a.team_id = b.team_id;

UPDATE Players 
SET position = NULL 
WHERE role = 'goalkeeper';

UPDATE Matches 
SET home_score = NULL, away_score = NULL 
WHERE date > CURRENT_DATE;

UPDATE Tournaments
SET status = 'scheduled', winner = NULL
WHERE year > EXTRACT(YEAR FROM CURRENT_DATE);

UPDATE Tournaments
SET status = 'finished'
WHERE year < EXTRACT(YEAR FROM CURRENT_DATE);

UPDATE Matches m
SET home_score = NULL, away_score = NULL
FROM Tournaments t
WHERE m.tournament_id = t.tournament_id
  AND t.status = 'scheduled';

UPDATE Tournament_Teams tt
SET points = 0
FROM Tournaments t
WHERE tt.tournament_id = t.tournament_id
  AND t.status = 'scheduled';

UPDATE Teams t
SET representative_name = (
    SELECT p.name || ' ' || p.surname
    FROM Players p
    WHERE p.team_id = t.team_id
      AND p.is_captain = true
    LIMIT 1
)
WHERE EXISTS (
    SELECT 1 FROM Players p 
    WHERE p.team_id = t.team_id 
      AND p.is_captain = true
);

UPDATE Tournaments t
SET winner = (
    SELECT tt.team_id
    FROM Tournament_Teams tt
    WHERE tt.tournament_id = t.tournament_id
    ORDER BY tt.points DESC
    LIMIT 1
)
WHERE t.status = 'finished'
  AND EXISTS (
      SELECT 1 FROM Tournament_Teams tt 
      WHERE tt.tournament_id = t.tournament_id
  );

DELETE FROM Players p1
WHERE EXISTS (
    SELECT 1 
    FROM Players p2
    WHERE p1.player_id > p2.player_id
      AND p1.name = p2.name
      AND p1.surname = p2.surname
      AND p1.team_id != p2.team_id
);


ALTER TABLE Teams ENABLE TRIGGER ALL;
ALTER TABLE Referees ENABLE TRIGGER ALL;
ALTER TABLE Players ENABLE TRIGGER ALL;
ALTER TABLE Tournaments ENABLE TRIGGER ALL;
ALTER TABLE Matches ENABLE TRIGGER ALL;
ALTER TABLE Match_Events ENABLE TRIGGER ALL;
ALTER TABLE Tournament_Teams ENABLE TRIGGER ALL;
ALTER TABLE tournament_teams
ADD CONSTRAINT tournament_teams_tournament_id_team_id_key
UNIQUE (tournament_id, team_id);


SELECT 'Teams' as table_name, COUNT(*) as count FROM Teams
UNION ALL
SELECT 'Referees', COUNT(*) FROM Referees
UNION ALL
SELECT 'Players', COUNT(*) FROM Players
UNION ALL
SELECT 'Tournaments', COUNT(*) FROM Tournaments
UNION ALL
SELECT 'Matches', COUNT(*) FROM Matches
UNION ALL
SELECT 'Match_Events', COUNT(*) FROM Match_Events
UNION ALL
SELECT 'Tournament_Teams', COUNT(*) FROM Tournament_Teams;
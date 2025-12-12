CREATE OR REPLACE FUNCTION MatchDateResultCheck()
RETURNS TRIGGER AS $$
BEGIN 
    IF NEW.date > CURRENT_DATE THEN 
        IF NEW.home_score IS NOT NULL OR NEW.away_score IS NOT NULL THEN 
            NEW.home_score = NULL;
            NEW.away_score = NULL; 
            RAISE NOTICE 'Utakmica još nije održana. Rezultati i postavljeni na NULL.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckMatchDateResult
    BEFORE INSERT OR UPDATE ON Matches
    FOR EACH ROW 
    EXECUTE FUNCTION MatchDateResultCheck();


CREATE OR REPLACE FUNCTION GolakeeperPositionCheck()
RETURNS TRIGGER AS $$ 
BEGIN 
    IF NEW.role = 'goalkeeper' THEN 
        NEW.position = NULL; 
        RAISE NOTICE 'Uloga golman. Pozicija stavljena na NULL.';
    END IF; 

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckGoalkeeperPosition
    BEFORE INSERT OR UPDATE ON Players
    FOR EACH ROW
    EXECUTE FUNCTION GolakeeperPositionCheck();


CREATE OR REPLACE FUNCTION CheckMatchInTournament()
RETURNS TRIGGER AS $$
DECLARE
    start_year INT;
BEGIN
    SELECT year 
    INTO start_year
    FROM Tournaments 
    WHERE tournament_id = NEW.Tournament;

    IF EXTRACT(YEAR FROM NEW.date) != start_year THEN
        RAISE EXCEPTION 'Utakmica mora biti za vrijeme turnira.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER MatchInTournamentCheck
    BEFORE INSERT OR UPDATE ON Matches
    FOR EACH ROW
    EXECUTE FUNCTION CheckMatchInTournament();


CREATE OR REPLACE FUNCTION TournamentStatusCheck()
RETURNS TRIGGER AS $$ 
BEGIN 
    IF NEW.year > EXTRACT(YEAR FROM CURRENT_DATE) THEN 
        NEW.status = 'scheduled';
        NEW.winner = NULL;
        RAISE NOTICE 'Turnir zakazan za budući datum. Status promijenjen u scheduled i uklonjen pobjednik.';
    ELSIF NEW.year < EXTRACT(YEAR FROM CURRENT_DATE) THEN 
        NEW.status = 'finished';
        RAISE NOTICE 'Datum turnira je prošao. Status promijenjen u finished.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckTournamentStatus
    BEFORE INSERT OR UPDATE ON Tournaments
    FOR EACH ROW
    EXECUTE FUNCTION TournamentStatusCheck();


CREATE OR REPLACE FUNCTION TeamInTournamentCheck()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(
        SELECT 1 
        FROM Tournament_Teams
        WHERE team_id = NEW.team_home
            AND tournament_id = NEW.tournament_id
    ) THEN 
        RAISE EXCEPTION 'Tim nije na ovom turniru.';
    END IF; 

    IF NOT EXISTS(
        SELECT 1
        FROM Tournament_Teams
        WHERE team_id = NEW.team_away
            AND tournament_id = NEW.tournament_id
    ) THEN 
        RAISE EXCEPTION 'Tim nije na ovom turniru.';
    END IF;  

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckTeamInTournament
    BEFORE INSERT OR UPDATE ON Matches
    FOR EACH ROW 
    EXECUTE FUNCTION TeamInTournamentCheck(); 


CREATE OR REPLACE FUNCTION PlayerTeamOverlapCheck()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Players p
        WHERE p.player_id != COALESCE(NEW.player_id, -1) 
          AND p.name = NEW.name
          AND p.surname = NEW.surname
          AND p.team_id != NEW.team_id
    ) THEN
        RAISE EXCEPTION 'Igrač je već u drugom timu.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckPlayerTeamOverlap
    BEFORE INSERT OR UPDATE ON Players
    FOR EACH ROW
    EXECUTE FUNCTION PlayerTeamOverlapCheck();


CREATE OR REPLACE FUNCTION CheckMatchOverlap()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Matches m
        WHERE m.match_id != COALESCE(NEW.match_id, -1)
        AND ((m.team_home = NEW.team_home OR m.team_away = NEW.team_home)
            OR (m.team_home = NEW.team_away OR m.team_away = NEW.team_away))
        AND m.date::date = NEW.date::date
    ) THEN
        RAISE EXCEPTION 'Tim već ima utakmicu za taj datum.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER MatchOverlapCheck
    BEFORE INSERT OR UPDATE ON Matches
    FOR EACH ROW
    EXECUTE FUNCTION CheckMatchOverlap();


CREATE OR REPLACE FUNCTION TeamRepresentativeCheck()
RETURNS TRIGGER AS $$ 
DECLARE
    captain_name TEXT;
BEGIN 
    IF NEW.is_captain = true THEN 
        UPDATE Teams
        SET representative_name = NEW.name || ' ' || NEW.surname,
            updated_at = CURRENT_TIMESTAMP
        WHERE team_id = NEW.team_id;
    END IF;

    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckTeamRepresentative
    AFTER INSERT OR UPDATE ON Players
    FOR EACH ROW
    EXECUTE FUNCTION TeamRepresentativeCheck();


CREATE OR REPLACE FUNCTION TournamentScheduledPointsCheck()
RETURNS TRIGGER AS $$ 
DECLARE
    tournament_status Status;
BEGIN 
    SELECT status 
    INTO tournament_status
    FROM Tournaments
    WHERE tournament_id = NEW.tournament_id;
    
    IF tournament_status = 'scheduled' THEN 
        NEW.points = 0; 
        RAISE NOTICE 'Turnir zakazan za budući datum. Bodovi postavljeni na 0.';
    END IF; 

    RETURN NEW; 
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER CheckTournamentScheduledPoints
    AFTER INSERT OR UPDATE ON Tournament_Teams
    FOR EACH ROW 
    EXECUTE FUNCTION TournamentScheduledPointsCheck();


CREATE OR REPLACE FUNCTION UpdateTournamentWinner()
RETURNS TRIGGER AS $$ 
DECLARE
    tournament_status Status;
    winning_team_id INT;
BEGIN 
    SELECT status INTO tournament_status
    FROM Tournaments
    WHERE tournament_id = NEW.tournament_id;
    
    IF tournament_status = 'finished' THEN 
        SELECT team_id INTO winning_team_id
        FROM Tournament_Teams 
        WHERE tournament_id = NEW.tournament_id
        ORDER BY points DESC
        LIMIT 1;

        UPDATE Tournaments
        SET winner = winning_team_id
        WHERE tournament_id = NEW.tournament_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateWinnerOnPointsChange
    AFTER INSERT OR UPDATE ON Tournament_Teams
    FOR EACH ROW 
    EXECUTE FUNCTION UpdateTournamentWinner();

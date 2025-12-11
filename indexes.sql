CREATE INDEX idx_players_team_id ON Players(team_id);

CREATE INDEX idx_matches_tournament_id ON Matches(tournament_id);

CREATE INDEX idx_matches_team_home ON Matches(team_home);

CREATE INDEX idx_matches_team_away ON Matches(team_away);

CREATE INDEX idx_matches_referee_id ON Matches(referee_id);

CREATE INDEX idx_match_events_match_id ON Match_Events(match_id);

CREATE INDEX idx_match_events_player_id ON Match_Events(player_id);

CREATE INDEX idx_tournament_teams_tournament_id ON Tournament_Teams(tournament_id);

CREATE INDEX idx_tournament_teams_team_id ON Tournament_Teams(team_id);

CREATE INDEX idx_tournaments_winner ON Tournaments(winner);


ANALYZE Teams;
ANALYZE Players;
ANALYZE Matches;
ANALYZE Match_Events;
ANALYZE Tournaments;
ANALYZE Tournament_Teams;
ANALYZE Referees;
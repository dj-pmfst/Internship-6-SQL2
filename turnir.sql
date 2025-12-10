CREATE TYPE Status AS ENUM('ongoing', 'finished', 'scheduled');
CREATE TYPE Role AS ENUM('goalkeeper', 'forward', 'midfield', 'back');
CREATE TYPE Player_Position AS ENUM('centre', 'left', 'right');
CREATE TYPE Phase AS ENUM('finals', 'semifinals', 'quarterfinals', 'round_of_16', 'groups');
CREATE TYPE Events AS ENUM('goal', 'red card', 'yellow card');


CREATE TABLE Teams (
	team_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	country VARCHAR(100) NOT NULL,
	contact_phone VARCHAR(20),
    representative_name VARCHAR(100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Referees (
	referee_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL, 
	dob DATE NOT NULL,
	country VARCHAR(100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK (dob < CURRENT_DATE - INTERVAL '18 years')
);

CREATE TABLE Players (
	player_id SERIAL PRIMARY KEY, 
	team_id INT NOT NULL REFERENCES Teams(team_id),
	name VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL, 
	dob DATE NOT NULL,
	country VARCHAR(100),
	role Role NOT NULL,
	position Player_Position,
	is_captain BOOLEAN NOT NULL DEFAULT false,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK (dob < CURRENT_DATE - INTERVAL '18 years')
);

CREATE TABLE Tournaments (
	tournament_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	year INT NOT NULL,
	location VARCHAR(100) NOT NULL,
	status Status NOT NULL DEFAULT 'scheduled', 
	winner INT REFERENCES Teams(team_id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Matches (
	match_id SERIAL PRIMARY KEY,
	tournament_id INT NOT NULL REFERENCES Tournaments(tournament_id),
	date TIMESTAMP NOT NULL,
	team_home INT NOT NULL REFERENCES Teams(team_id),
	team_away INT NOT NULL REFERENCES Teams(team_id),
	phase Phase NOT NULL,
	referee_id INT NOT NULL REFERENCES Referees(referee_id),
	home_score INT NOT NULL DEFAULT 0,
	away_score INT NOT NULL DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE(tournament_id, team_home, team_away, phase)
);

CREATE TABLE Match_Events (
	event_id SERIAL PRIMARY KEY,
	type Events NOT NULL,
	player_id INT NOT NULL REFERENCES Players(player_id),
	match_id INT NOT NULL REFERENCES Matches(match_id),
	minute INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK (minute >= 0 AND minute <= 120)
);

CREATE TABLE Tournament_Teams (
	id SERIAL PRIMARY KEY,
	tournament_id INT NOT NULL REFERENCES Tournaments(tournament_id),
	team_id INT NOT NULL REFERENCES Teams(team_id),
	points INT NOT NULL DEFAULT 0,
	final_position INT,
	phase_reached Phase,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE(tournament_id, team_id)
);
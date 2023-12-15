-- Create an schema and tables for permanent tables
CREATE SCHEMA IF NOT EXISTS olympic;

-- Create NOC Region Table
DROP TABLE IF EXISTS olympic.noc_region;

CREATE TABLE olympic.noc_region (
	noc          		VARCHAR(3),
	region       		VARCHAR(100),
	note         		TEXT,
	PRIMARY KEY (noc)
);

-- Insert into NOC Region Table from CSV file
COPY olympic.noc_region
FROM '\data\noc_regions.csv'
WITH DELIMITER ',' HEADER CSV;

-- Create Athlete Events Table
DROP TABLE IF EXISTS olympic.athlete_events;

CREATE TABLE olympic.athlete_events (
	event_id             SERIAL,
	athlete_id           TEXT,
	name                 TEXT,
	sex                  CHAR(1),
	age                  SMALLINT,
	height               NUMERIC,
	weight               NUMERIC,
	team                 VARCHAR(50),
	noc                  VARCHAR(3) REFERENCES olympic.noc_region (noc),
	games                TEXT,
	year                 SMALLINT,
	season               VARCHAR(10),
	city                 TEXT,
	sport                TEXT,
	event                TEXT,
	medal                VARCHAR(10),
	PRIMARY KEY (event_id)
);

-- Insert into Athlete Events Table from CSV file
COPY olympic.athlete_events (athlete_id, name, sex, age, height, weight, team, noc, games, year, season, city, sport, event, medal)
FROM '\data\athlete_events.csv'
WITH DELIMITER ',' HEADER CSV QUOTE '"' NULL 'NA';



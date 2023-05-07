-- GRANT ALL ON DATABASE info21 TO janiecee;
-- ALTER DATABASE info21 OWNER TO janiecee;
CREATE TABLE Peers (
    Nickname VARCHAR PRIMARY KEY,
    Birthday DATE NOT NULL
);
CREATE TABLE Tasks (
    Title VARCHAR PRIMARY KEY,
    ParentTask VARCHAR,
    MaxXP INT NOT NULL
);
CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');
CREATE TABLE Checks (
    id SERIAL PRIMARY KEY,
    Peer VARCHAR NOT NULL,
    Task VARCHAR NOT NULL,
    Date DATE NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
    FOREIGN KEY (Task) REFERENCES Tasks(Title)
);
CREATE TABLE P2P (
    id SERIAL PRIMARY KEY,
    CheckNum BIGINT NOT NULL,
    CheckingPeer VARCHAR NOT NULL,
    State check_status,
    Time TIMESTAMP,
    FOREIGN KEY (CheckNum) REFERENCES Checks(id),
    UNIQUE (CheckNum, CheckingPeer)
);
CREATE TABLE Verter (
    id SERIAL PRIMARY KEY,
    CheckNum BIGINT NOT NULL,
    State check_status NOT NULL,
    time TIMESTAMP NOT NULL,
    FOREIGN KEY (CheckNum) REFERENCES Checks(id)
);
CREATE TABLE TransferredPoints (
    id SERIAL PRIMARY KEY,
    CheckingPeer VARCHAR NOT NULL,
    CheckedPeer VARCHAR NOT NULL,
    PointsAmount INT NOT NULL
);
CREATE TABLE Friends (
    id SERIAL PRIMARY KEY,
    Peer1 VARCHAR NOT NULL,
    Peer2 VARCHAR NOT NULL,
    FOREIGN KEY (Peer1) REFERENCES Peers(Nickname),
    FOREIGN KEY (Peer2) REFERENCES Peers(Nickname)
);
CREATE TABLE Recommendations (
    id SERIAL PRIMARY KEY,
    Peer VARCHAR NOT NULL,
    RecommendedPeer VARCHAR NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
    FOREIGN KEY (RecommendedPeer) REFERENCES Peers(Nickname)
);
CREATE TABLE XP (
    id SERIAL PRIMARY KEY,
    CheckNum BIGINT NOT NULL,
    XPAmount INT NOT NULL,
    FOREIGN KEY (CheckNum) REFERENCES Checks(id)
);
CREATE TABLE TimeTracking (
    id SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    State INT CHECK (state IN (1, 2)),
    FOREIGN KEY (Peer) REFERENCES Peers(Nickname)
);
-- DROP PROCEDURE import_csv_data;
-- Create procedure to import in csv file 
CREATE OR REPLACE PROCEDURE import_csv_data(
        IN table_name VARCHAR,
        IN file_path VARCHAR,
        IN delimiter VARCHAR
    ) LANGUAGE plpgsql AS $$ BEGIN --
    -- Create temproary table
    EXECUTE format(
        'CREATE TEMPORARY TABLE tmp_table AS
SELECT *
FROM %I',
        table_name
    );
-- Load data from CSV to CACHE TABLE
EXECUTE format(
    'COPY tmp_table FROM %L WITH (FORMAT CSV, DELIMITER %L)',
    file_path,
    delimiter
);
-- Insert data from CACHE TABLE to table_name
EXECUTE format(
    'INSERT INTO %I SELECT * FROM tmp_table',
    table_name
);
-- Drop CACHE TABLE
EXECUTE 'TRUNCATE TABLE tmp_table';
END;
$$;
-- Create procedure to export from csv file 
CREATE OR REPLACE PROCEDURE export_csv_data(
        IN table_name VARCHAR,
        IN file_path VARCHAR,
        IN delimiter VARCHAR
    ) LANGUAGE plpgsql AS $$ BEGIN EXECUTE format(
        'COPY %I TO %L WITH (FORMAT CSV, DELIMITER %L)',
        table_name,
        file_path,
        delimiter
    );
END;
$$;
-- Run from SU POSTGRES (sudo su postgres; psql; GRANT pg_write_server_files TO janiecee; GRANT pg_read_server_files TO janiecee;)
CALL import_csv_data(
    'peers',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Peers.csv',
    ','
);
CALL import_csv_data(
    'tasks',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Tasks.csv',
    ','
);
CALL import_csv_data(
    'checks',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Checks.csv',
    ','
);
DROP OWNED BY janiecee;
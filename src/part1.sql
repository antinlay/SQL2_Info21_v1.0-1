-- GRANT ALL ON DATABASE info21 TO janiecee;
-- ALTER DATABASE info21 OWNER TO janiecee;
CREATE TABLE peers (
    nickname VARCHAR PRIMARY KEY,
    birthday DATE NOT NULL
);
CREATE TABLE tasks (
    title VARCHAR PRIMARY KEY,
    parent_task VARCHAR,
    max_xp INT NOT NULL
);
CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');
CREATE TABLE checks (
    id SERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL,
    task VARCHAR NOT NULL,
    date_check DATE NOT NULL
);
CREATE TABLE p2p (
    id SERIAL PRIMARY KEY,
    check_num INT NOT NULL,
    checking_peer VARCHAR NOT NULL,
    check_state check_status,
    time_check TIME NOT NULL
);
CREATE TABLE verter (
    id SERIAL PRIMARY KEY,
    check_num INT NOT NULL,
    check_state check_status NOT NULL,
    time_check TIME NOT NULL
);
CREATE TABLE transfered_points (
    id SERIAL PRIMARY KEY,
    checking_peer VARCHAR NOT NULL,
    checked_peer VARCHAR NOT NULL,
    points_amount INT NOT NULL
);
CREATE TABLE friend (
    id SERIAL PRIMARY KEY,
    peer1 VARCHAR NOT NULL,
    peer2 VARCHAR NOT NULL
);
CREATE TABLE recomendations (
    id SERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL,
    recomended_peer VARCHAR NOT NULL
);
CREATE TABLE xp (
    id SERIAL PRIMARY KEY,
    check_num INT NOT NULL,
    xp_amount INT NOT NULL
);
CREATE TABLE time_tracking (
    id SERIAL PRIMARY KEY,
    peer VARCHAR,
    date_state DATE NOT NULL,
    time_state TIME NOT NULL,
    peer_state INT CHECK (peer_state IN (1, 2))
);
ALTER TABLE checks
ADD CONSTRAINT fk_checks_peer FOREIGN KEY (peer) REFERENCES peers(nickname);
ALTER TABLE checks
ADD CONSTRAINT fk_checks_task FOREIGN KEY (task) REFERENCES tasks(title);
ALTER TABLE time_tracking
ADD CONSTRAINT fk_time_tracking_peer FOREIGN KEY (peer) REFERENCES peers(nickname);
ALTER TABLE p2p
ADD CONSTRAINT fk_p2p_check_num FOREIGN KEY (check_num) REFERENCES checks(id);
ALTER TABLE p2p
ADD CONSTRAINT uk_p2p_check UNIQUE (check_num, checking_peer, check_state);
-- WHERE check_state IN ('Start');
ALTER TABLE friend
ADD CONSTRAINT fk_friend_peer1 FOREIGN KEY (peer1) REFERENCES peers(nickname);
ALTER TABLE friend
ADD CONSTRAINT fk_friend_peer2 FOREIGN KEY (peer2) REFERENCES peers(nickname);
ALTER TABLE friend
ADD CONSTRAINT uk_peer1_peer2 UNIQUE (peer1, peer2);
-- ALTER TABLE friend
-- ADD CONSTRAINT chk_peer1_peer2 CHECK (peer1 < peer2);
ALTER TABLE recomendations
ADD CONSTRAINT fk_recomendations_peer FOREIGN KEY (peer) REFERENCES peers(nickname);
ALTER TABLE recomendations
ADD CONSTRAINT fk_recomendations_recomended_peer FOREIGN KEY (recomended_peer) REFERENCES peers(nickname);
ALTER TABLE xp
ADD CONSTRAINT fk_xp_check_num FOREIGN KEY (check_num) REFERENCES checks(id);
-- DROP PROCEDURE import_csv_data;
-- Create procedure to import in csv file 
CREATE OR REPLACE PROCEDURE import_csv_data(
        IN table_name VARCHAR,
        IN file_path VARCHAR,
        IN delimiter VARCHAR
    ) LANGUAGE plpgsql AS $$ BEGIN --
    EXECUTE format(
    'COPY %I FROM %L DELIMITER %L CSV',
    table_name,
    file_path,
    delimiter
);
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
CALL import_csv_data(
    'p2p',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/P2P.csv',
    ','
);
CALL import_csv_data(
    'p2p',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/P2P.csv',
    ','
);
CALL import_csv_data(
    'verter',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Verter.csv',
    ','
);
CALL import_csv_data(
    'transfered_points',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Transfered_points.csv',
    ','
);
CALL import_csv_data(
    'friend',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Friends.csv',
    ','
);
CALL import_csv_data(
    'recomendations',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Recomendations.csv',
    ','
);
CALL import_csv_data(
    'xp',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Xp.csv',
    ','
);
CALL import_csv_data(
    'time_tracking',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Time_tracking.csv',
    ','
);
DROP OWNED BY janiecee;
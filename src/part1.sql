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
    date_check DATE NOT NULL,
    CONSTRAINT fk_checks_peer FOREIGN KEY (peer) REFERENCES peers(nickname),
    CONSTRAINT fk_checks_task FOREIGN KEY (task) REFERENCES tasks(title)
);
CREATE TABLE p2p (
    id SERIAL PRIMARY KEY,
    check_num BIGINT NOT NULL,
    checking_peer VARCHAR NOT NULL,
    check_state check_status,
    time_check TIME NOT NULL,
    CONSTRAINT fk_p2p_check_num FOREIGN KEY (check_num) REFERENCES checks(id),
    CONSTRAINT uk_p2p_check UNIQUE (check_num, checked_peer, check_state) -- WHERE check_state IN ('Start');
);
CREATE TABLE verter (
    id SERIAL PRIMARY KEY,
    check_num INT NOT NULL,
    check_state check_status NOT NULL,
    time_check TIME NOT NULL,
    CONSTRAINT fk_verter_check_num FOREIGN KEY (check_num) REFERENCES checks(id)
    WHERE EXISTS (
            SELECT 1
            FROM p2p
            WHERE p2p.check_num = checks.id
                AND p2p.check_state = 'Success'
        );
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
    peer2 VARCHAR NOT NULL,
    CONSTRAINT fk_friend_peer1 FOREIGN KEY (peer1) REFERENCES peers(nickname),
    CONSTRAINT fk_friend_peer2 FOREIGN KEY (peer2) REFERENCES peers(nickname),
    CONSTRAINT uk_peer1_peer2 UNIQUE (peer1, peer2),
    CONSTRAINT chk_peer1_peer2 CHECK (peer1 < peer2)
);
CREATE TABLE recomendations (
    id SERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL,
    recomended_peer VARCHAR NOT NULL,
    CONSTRAINT fk_recomendations_peer FOREIGN KEY (peer) REFERENCES peers(nickname),
    CONSTRAINT fk_recomendations_recomended_peer FOREIGN KEY (recomended_peer) REFERENCES peers(nickname)
);
CREATE TABLE xp (
    id SERIAL PRIMARY KEY,
    check_num BIGINT NOT NULL,
    xp_amount INT NOT NULL,
    CONSTRAINT fk_xp_check_num FOREIGN KEY (check_num) REFERENCES checks(id)
);
CREATE TABLE time_tracking (
    id SERIAL PRIMARY KEY,
    peer VARCHAR,
    date_state DATE NOT NULL,
    time_state TIME NOT NULL,
    peer_state INT CHECK (peer_state IN (1, 2)),
    CONSTRAINT fk_time_tracking_peer FOREIGN KEY (peer) REFERENCES peers(nickname)
);
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
    'p2p',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/P2P.csv',
    ','
);
CALL import_csv_data(
    'checks',
    '/home/janiecee/Documents/github/SQL2_Info21_v1.0-1/src/Checks.csv',
    ','
);
DROP OWNED BY janiecee;
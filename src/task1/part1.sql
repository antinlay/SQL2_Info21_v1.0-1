CREATE TABLE IF NOT EXISTS Peers (
	Nickname VARCHAR PRIMARY KEY,
	Birthday DATE NOT NULL
);

CREATE TABLE Tasks (
	Title VARCHAR(128) PRIMARY KEY,
	ParentTask VARCHAR(128),
	MaxXP INT NOT NULL
);


CREATE TABLE Checks (
	id SERIAL PRIMARY KEY,
	Peer VARCHAR(128) NOT NULL,
	Task VARCHAR(128) NOT NULL,
	Date DATE,
	CONSTRAINT fk_checks_peer FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
	CONSTRAINT fk_checks_task FOREIGN KEY (Task) REFERENCES Tasks(Title)
);

CREATE TABLE P2P (
	id SERIAL PRIMARY KEY,
	Check_ INT NOT NULL,
	ChekingPeer VARCHAR(128) NOT NULL,
	State_ INT NOT NULL,
	Time_ TIME NOT NULL,
	CONSTRAINT fk_p2p_checks FOREIGN KEY (Check_) REFERENCES Checks(id),
	CONSTRAINT fk_peer_checks FOREIGN KEY (ChekingPeer) REFERENCES Peers(Nickname),
	CONSTRAINT check_state CHECK (
	State_ = 0
	or State_ = 1
	or State_ = 2
	)
);


CREATE TABLE Verter (
	id SERIAL PRIMARY KEY,
	Check_ INT NOT NULL,
	State_ INT NOT NULL,
	Time_ TIME NOT NULL,
	CONSTRAINT fk_verter_checks FOREIGN KEY (Check_) REFERENCES Checks(id),
	CONSTRAINT check_state CHECK (
	State_ = 0
	or State_ = 1
	or State_ = 2
	)
);



CREATE TABLE TransferredPoints (
	id SERIAL PRIMARY KEY,
	CheckingPeer VARCHAR(128) NOT NULL,
	CheckedPeer VARCHAR(128) NOT NULL,
	PointsAmount INT NOT NULL,
	CONSTRAINT fk_tranfpoint_checking_peer FOREIGN KEY (CheckingPeer) REFERENCES Peers(Nickname),
	CONSTRAINT fk_tranfpoint_checked_peer FOREIGN KEY (CheckedPeer) REFERENCES Peers(Nickname)
);

CREATE TABLE Friends (
	id SERIAL PRIMARY KEY,
	Peer1 VARCHAR(128),
	Peer2 VARCHAR(128),
	CONSTRAINT fk_peer1_peers FOREIGN KEY (Peer1) REFERENCES Peers(Nickname),
	CONSTRAINT fk_peer2_peers FOREIGN KEY (Peer2) REFERENCES Peers(Nickname),
	CONSTRAINT check_eq_peers CHECK (Peer1 <> Peer2)
);

CREATE TABLE Recommendations (
	id SERIAL PRIMARY KEY,
	Peer VARCHAR(128) NOT NULL,
	RecommendedPeer VARCHAR(128) NOT NULL,
	CONSTRAINT fk_peer_peers FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
	CONSTRAINT fk_recommendedPeer_peers FOREIGN KEY (RecommendedPeer) REFERENCES Peers(Nickname),
	CONSTRAINT check_eq_peers CHECK (Peer <> RecommendedPeer)
);

CREATE TABLE XP (
	id SERIAL PRIMARY KEY,
	Check_ INT NOT NULL,
	XPAmount INT,
	CONSTRAINT fk_xp_checks FOREIGN KEY (Check_) REFERENCES Checks(id)
);

CREATE TABLE TimeTracking (
	id SERIAL PRIMARY KEY,
	Peer VARCHAR(128) NOT NULL,
	Date_ DATE NOT NULL,
	Time_ TIME NOT NULL,
	State_ INT CHECK (State_ IN (0, 1, 2)),
	CONSTRAINT fk_timetrack_peers FOREIGN KEY (Peer) REFERENCES Peers(Nickname)
);


CREATE OR REPLACE PROCEDURE import_data_csv(table_name text, file_path text) AS $$
BEGIN
  EXECUTE format('COPY %I FROM %L DELIMITER %L CSV', table_name, file_path, ',');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE export_data_csv(table_name text, file_path text) AS $$
BEGIN
  EXECUTE format('COPY %I TO %L DELIMITER %L CSV', table_name, file_path, ',');
END;
$$ LANGUAGE plpgsql;


CALL import_data_csv('peers', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/peers.csv');
CALL export_data_csv('peers', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/peers_exp.csv');
CALL import_data_csv('tasks', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/tasks_imp.csv');
CALL export_data_csv('tasks', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/tasks_exp.csv');
CALL import_data_csv('checks', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/checks_imp.csv');
CALL export_data_csv('checks', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/checks_exp.csv');
CALL import_data_csv('p2p', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/p2p_imp.csv');
CALL export_data_csv('p2p', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/p2p_exp.csv');
CALL import_data_csv('verter', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/verter_imp.csv');
CALL export_data_csv('verter', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/verter_exp.csv');
CALL import_data_csv('transferredpoints', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/transf_point_imp.csv');
CALL export_data_csv('transferredpoints', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/transf_point_exp.csv');
CALL import_data_csv('friends', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/friends_imp.csv');
CALL export_data_csv('friends', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/friends_exp.csv');
CALL import_data_csv('recommendations', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/recomendation_imp.csv');
CALL export_data_csv('recommendations', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/recomendation_exp.csv');
CALL import_data_csv('xp', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/xp_imp.csv');
CALL export_data_csv('xp', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/xp_exp.csv');
CALL import_data_csv('timetracking', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/timetracking_imp.csv');
CALL export_data_csv('timetracking', '/Users/merylpor/Desktop/SQL2_Info21_v1.0-1/src/task1/timetracking_exp.csv');







CREATE TABLE IF NOT EXISTS Peers (
	Nickname VARCHAR PRIMARY KEY,
	Birthday DATE NOT NULL
);

-- COPY Peers FROM '/Users/codela/Desktop/SQL2_Info21_v1.0-1/src/task1/peers.csv'
-- DELIMITER ',' CSV;
CREATE PROCEDURE import_csv(tab Table, filepath PATH)
LANGUAGE SQL
AS $$
COPY tab FROM filepath DELIMITER ',' CSV;
$$;

CALL import_csv(Peers, '/Users/codela/Desktop/SQL2_Info21_v1.0-1/src/task1/peers.csv');

-- CREATE TABLE Tasks (
-- 	Title VARCHAR PRIMARY KEY,
-- 	ParentTask VARCHAR(128),
-- 	MaxXP INT,
-- 	CONSTRAINT fk_parent_task FOREIGN KEY (ParentTask) REFERENCES Tasks(Title)
-- );

-- CREATE TABLE Checks (
-- 	id SERIAL PRIMARY KEY,
-- 	Peer VARCHAR(128) NOT NULL,
-- 	Task VARCHAR(128) NOT NULL,
-- 	Date DATE,
-- 	CONSTRAINT fk_checks_peer FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
-- 	CONSTRAINT fk_checks_task FOREIGN KEY (Task) REFERENCES Tasks(Title)
-- );

-- CREATE TABLE P2P (
-- 	id SERIAL PRIMARY KEY,
-- 	Check_ INT NOT NULL,
-- 	ChekingPeer VARCHAR(128) NOT NULL,
-- 	State_ INT NOT NULL,
-- 	Time_ TIME NOT NULL,
-- 	CONSTRAINT fk_p2p_checks FOREIGN KEY (Check_) REFERENCES Checks(id),
-- 	CONSTRAINT fk_peer_checks FOREIGN KEY (ChekingPeer) REFERENCES Peers(Nickname),
-- 	CONSTRAINT check_state CHECK (
-- 	State_ = 0
-- 	or State_ = 1
-- 	or State_ = 2
-- 	)
-- );

-- CREATE TABLE Verter (
-- 	id SERIAL PRIMARY KEY,
-- 	Check_ INT NOT NULL,
-- 	State_ INT NOT NULL,
-- 	Time_ TIME NOT NULL,
-- 	CONSTRAINT fk_verter_checks FOREIGN KEY (Check_) REFERENCES Checks(id),
-- 	CONSTRAINT check_state CHECK (
-- 	State_ = 0
-- 	or State_ = 1
-- 	or State_ = 2
-- 	)
-- );

-- CREATE TABLE TransferredPoints (
-- 	id SERIAL PRIMARY KEY,
-- 	CheckingPeer VARCHAR(128) NOT NULL,
-- 	CheckedPeer VARCHAR(128) NOT NULL,
-- 	PointsAmount INT NOT NULL,
-- 	CONSTRAINT fk_tranfpoint_checking_peer FOREIGN KEY (CheckingPeer) REFERENCES Peers(Nickname),
-- 	CONSTRAINT fk_tranfpoint_checked_peer FOREIGN KEY (CheckedPeer) REFERENCES Peers(Nickname)
-- );

-- CREATE TABLE Friends (
-- 	id SERIAL PRIMARY KEY,
-- 	Peer1 VARCHAR(128),
-- 	Peer2 VARCHAR(128),
-- 	CONSTRAINT fk_peer1_peers FOREIGN KEY (Peer1) REFERENCES Peers(Nickname),
-- 	CONSTRAINT fk_peer2_peers FOREIGN KEY (Peer2) REFERENCES Peers(Nickname),
-- 	CONSTRAINT check_eq_peers CHECK (Peer1 <> Peer2)
-- );

-- CREATE TABLE Recommendations (
-- 	id SERIAL PRIMARY KEY,
-- 	Peer VARCHAR(128) NOT NULL,
-- 	RecommendedPeer VARCHAR(128) NOT NULL,
-- 	CONSTRAINT fk_peer_peers FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
-- 	CONSTRAINT fk_recommendedPeer_peers FOREIGN KEY (RecommendedPeer) REFERENCES Peers(Nickname),
-- 	CONSTRAINT check_eq_peers CHECK (Peer <> RecommendedPeer)
-- );

-- CREATE TABLE XP (
-- 	id SERIAL PRIMARY KEY,
-- 	Check_ INT NOT NULL,
-- 	XPAmount INT,
-- 	CONSTRAINT fk_xp_checks FOREIGN KEY (Check_) REFERENCES Checks(id)
-- );

-- CREATE TABLE TimeTracking (
-- 	id SERIAL PRIMARY KEY,
-- 	Peer VARCHAR(128) NOT NULL,
-- 	Date_ DATE NOT NULL,
-- 	Time_ TIME NOT NULL,
-- 	State_ INT CHECK (State_ IN (0, 1, 2)),
-- 	CONSTRAINT fk_timetrack_peers FOREIGN KEY (Peer) REFERENCES Peers(Nickname)
-- );




















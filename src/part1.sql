CREATE TABLE TimeTracking (
    id bigint primary key,
    Peer varchar not null,
    Date date not null,
    Time time not null,
    State varchar not null
);
-- gbfbdskfhksdjhfldsdfjdsllf
--
CREATE TABLE Peers (Nickname VARCHAR PRIMARY KEY, Birthday DATE NOT NULL
);
CREATE TABLE Tasks (
    Title VARCHAR PRIMARY KEY,
    ParentTask VARCHAR not null,
    MaxXP int not null
);
CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');
CREATE TABLE P2P (
    id SERIAL PRIMARY KEY,
    Check BIGINT NOT NULL,
    CheckingPeer VARCHAR NOT NULL,
    State check_status,
    Time TIMESTAMP,
    FOREIGN KEY (Check) REFERENCES Checks(id),
    UNIQUE (Check, CheckingPeer)
);
CREATE TABLE Verter (
    id SERIAL PRIMARY KEY,
    Check BIGINT NOT NULL,
    State check_status NOT NULL,
    time TIMESTAMP NOT NULL,
    FOREIGN KEY (Check) REFERENCES Checks(id)
);
CREATE TABLE Checks (
    id SERIAL PRIMARY KEY,
    Peer VARCHAR NOT NULL,
    Task VARCHAR NOT NULL,
    Date DATE NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers(Nickname),
    FOREIGN KEY (Task) REFERENCES Tasks(name)
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
    FOREIGN KEY (Peer2) REFERENCES Peers(nickname)
);
CREATE TABLE Recommendations (
    id SERIAL PRIMARY KEY,
    Peer VARCHAR NOT NULL,
    RecommendedPeer VARCHAR NOT NULL,
    FOREIGN KEY (peer_nickname) REFERENCES Peers(nickname),
    FOREIGN KEY (recommended_peer_nickname) REFERENCES Peers(nickname)
);
CREATE TABLE XP (
    id SERIAL PRIMARY KEY,
    Check BIGINT NOT NULL,
    XPAmount INT NOT NULL,
    FOREIGN KEY (check_id) REFERENCES Checks(id)
);
CREATE TABLE TimeTracking (
    id SERIAL PRIMARY KEY,
    peer_nickname VARCHAR,
    date DATE,
    time TIME,
    state INT CHECK (state IN (1, 2)),
    FOREIGN KEY (peer_nickname) REFERENCES Peers(nickname)
);
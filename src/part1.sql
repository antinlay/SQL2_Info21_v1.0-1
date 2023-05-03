CREATE TABLE Peers (
    Nickname VARCHAR PRIMARY KEY,
    Birthday DATE NOT NULL
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
    Check BIGINT NOT NULL,
    XPAmount INT NOT NULL,
    FOREIGN KEY (Check) REFERENCES Checks(id)
);
CREATE TABLE TimeTracking (
    State varchar not null id SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    State INT CHECK (state IN (1, 2)),
    FOREIGN KEY (Peer) REFERENCES Peers(Nickname)
);
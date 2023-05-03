CREATE TABLE Peers (
    Nickname varchar primary key,
    Birthday date not null
);
CREATE TABLE Checks (
    id bigint primary key,
    Peer varchar not null,
    Task varchar not null,
    Date date not null default date current_date
);
CREATE TABLE Verter (
    id bigint primary key,
    Check bigint not null,
    State varchar not null,
    Time time not null default current_time -- constraint fk_verter_checks_id foreign key (id) references Checks(id)
);
CREATE TABLE XP (
    id bigint primary key,
    Check bigint not null,
    XPAmount int not null
);
CREATE TABLE Tasks (
    Title varchar primary key,
    ParentTask varchar not null,
    MaxXP int not null
);
CREATE TABLE P2P (
    id bigint primary key,
    Check bigint not null,
    CheckingPeer varchar not null,
    State varchar not null,
    Time time not null default current_time
);
CREATE TABLE TransferredPoints (
    id bigint primary key,
    CheckingPeer varchar not null,
    CheckedPeer varchar not null,
    PointsAmount int not null
);
CREATE TABLE Friends (
    id bigint primary key,
    Peer1 varchar not null,
    Peer2 varchar not null
);
CREATE TABLE Recomendations (
    id bigint primary key,
    Peer varchar not null,
    RecommendedPeer varchar not null
);
CREATE TABLE TimeTracking (
    id bigint primary key,
    Peer varchar not null,
    Date date not null,
    Time time not null,
    State varchar not null
)
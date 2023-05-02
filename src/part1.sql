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
    Time time not null default current_time,
    constraint fk_verter_checks_id foreign key (id) references Checks(id)
);
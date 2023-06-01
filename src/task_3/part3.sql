-- 1) Write a function that returns the TransferredPoints table in a more human-readable form
CREATE OR REPLACE FUNCTION tp_human_view () RETURNS TABLE (
        Peer1 VARCHAR,
        Peer2 VARCHAR,
        PointsAmount INT
    ) AS $$ BEGIN RETURN QUERY
SELECT tp.checking_peer AS Peer1,
    tp.checked_peer AS Peer2,
    COALESCE(tp.points_amount, 0) - COALESCE(join_tp.points_amount, 0) AS PointsAmount
FROM transfered_points tp
    FULL JOIN transfered_points AS join_tp ON tp.checking_peer = join_tp.checked_peer
    AND join_tp.checking_peer = tp.checked_peer
WHERE tp.id < join_tp.id
    OR join_tp.id IS NULL
ORDER BY Peer1,
    Peer2;
END;
$$ LANGUAGE plpgsql;
SELECT *
FROM tp_human_view();
-- DROP FUNCTION tp_human_view;
-- 2) Write a function that returns a table of the following form: user name, name of the checked task, number of XP received
CREATE OR REPLACE FUNCTION checks_success () RETURNS TABLE (Peer VARCHAR, Task VARCHAR, Xp INT) AS $$ BEGIN RETURN QUERY
SELECT checks.peer AS Peer,
    checks.task AS Task,
    xp.xp_amount AS Xp
FROM checks
    JOIN p2p ON p2p.check_num = checks.id
    AND p2p.check_state = 'Success'
    JOIN verter ON verter.check_num = checks.id
    AND verter.check_state = 'Success'
    JOIN xp ON xp.check_num = checks.id
ORDER BY Peer;
END;
$$ LANGUAGE plpgsql;
SELECT *
FROM checks_success();
-- 3) Write a function that finds the peers who have not left campus for the whole day
CREATE OR REPLACE FUNCTION peer_not_left (target_date date) RETURNS TABLE (Peer VARCHAR) AS $$ BEGIN RETURN QUERY
SELECT tt.peer AS Peer
FROM time_tracking AS tt
WHERE peer_state = 1
    AND date_state = target_date
EXCEPT
SELECT tt.peer AS Peer
FROM time_tracking AS tt
WHERE peer_state = 2
    AND date_state = target_date;
END;
$$ LANGUAGE plpgsql;
SELECT *
FROM peer_not_left('2023-06-01');
-- INSERT INTO time_tracking
-- VALUES (7, 'shoredim', '2023-06-01', '09:00:00', 1);
-- INSERT INTO time_tracking
-- VALUES (8, 'shoredim', '2023-06-02', '00:01:00', 2);
-- 4) Calculate the change in the number of peer points of each peer using the TransferredPoints table
CREATE OR REPLACE PROCEDURE prp_change (IN cursor REFCURSOR = 'result_4') AS $$ BEGIN OPEN result_4 FOR
SELECT nickname,
    SUM(COALESCE(transfered_points.points_amount, 0))
FROM peers
    LEFT JOIN transfered_points ON transfered_points.checking_peer = peers.nickname
GROUP BY peers.nickname
ORDER BY nickname
END;
$$ LANGUAGE plpgsql;
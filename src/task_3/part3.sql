-- 1) Write a function that returns the transfered_points table in a more human-readable form
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
-- 4) Calculate the change in the number of peer points of each peer using the transfered_points table
CREATE OR REPLACE PROCEDURE prp_change (IN cursor REFCURSOR = 'result_p3_t4') AS $$ BEGIN OPEN cursor FOR WITH Peer1Trans AS (
        SELECT nickname,
            SUM(COALESCE(transfered_points.points_amount, 0)) AS sum_points
        FROM peers
            LEFT JOIN transfered_points ON transfered_points.checking_peer = peers.nickname
        GROUP BY peers.nickname
        ORDER BY nickname
    ),
    Peer2Trans AS (
        SELECT nickname,
            SUM(COALESCE(transfered_points.points_amount, 0)) AS sum_points
        FROM peers
            LEFT JOIN transfered_points ON transfered_points.checked_peer = peers.nickname
        GROUP BY peers.nickname
        ORDER BY nickname
    )
SELECT Peer2Trans.nickname AS Peer,
    Peer2Trans.sum_points - Peer1Trans.sum_points AS ChangePoints
FROM Peer2Trans
    JOIN Peer1Trans ON Peer1Trans.nickname = Peer2Trans.nickname
ORDER BY ChangePoints DESC;
END;
$$ LANGUAGE plpgsql;
-- DROP PROCEDURE prp_change;
-- Check procedure
CALL prp_change();
FETCH ALL
FROM "result_p3_t4";
-- 5) Calculate the change in the number of peer points of each peer using the table returned by the first function from Part 3
CREATE OR REPLACE PROCEDURE prp_change_tphuman (IN cursor REFCURSOR = 'result_p3_t5') AS $$ BEGIN OPEN cursor FOR WITH tp_human_view AS (
        SELECT *
        FROM tp_human_view()
    ),
    Peer1Trans AS (
        SELECT nickname,
            SUM(COALESCE(tp_human_view.PointsAmount, 0)) AS sum_points
        FROM peers
            LEFT JOIN tp_human_view ON tp_human_view.Peer1 = peers.nickname
        GROUP BY peers.nickname
        ORDER BY nickname
    ),
    Peer2Trans AS (
        SELECT nickname,
            SUM(COALESCE(tp_human_view.PointsAmount, 0)) AS sum_points
        FROM peers
            LEFT JOIN tp_human_view ON tp_human_view.Peer2 = peers.nickname
        GROUP BY peers.nickname
        ORDER BY nickname
    )
SELECT Peer2Trans.nickname AS Peer,
    Peer2Trans.sum_points - Peer1Trans.sum_points AS ChangePoints
FROM Peer2Trans
    JOIN Peer1Trans ON Peer1Trans.nickname = Peer2Trans.nickname
ORDER BY ChangePoints DESC;
END;
$$ LANGUAGE plpgsql;
CALL prp_change_tphuman();
FETCH ALL
FROM "result_p3_t5";
-- 6) Find the most frequently checked task for each day
CREATE OR REPLACE PROCEDURE freq_checked_task (IN cursor REFCURSOR = 'result_p3_t6') AS $$ BEGIN OPEN cursor FOR WITH checks_count AS (
        SELECT checks.date_check,
            checks.task,
            COUNT(*) AS amount
        FROM checks
        GROUP BY checks.date_check,
            checks.task
        ORDER BY checks.date_check
    ),
    max_of_count AS (
        SELECT checks_count.date_check,
            MAX(amount) AS max
        FROM checks_count
        GROUP BY checks_count.date_check
    )
SELECT TO_CHAR(checks_count.date_check, 'DD.MM.YYYY') AS Day,
    checks_count.task AS Task
FROM checks_count
    JOIN max_of_count ON max_of_count.date_check = checks_count.date_check
WHERE max_of_count.max = checks_count.amount;
END;
$$ LANGUAGE plpgsql;
CALL freq_checked_task();
FETCH ALL
FROM "result_p3_t6";
-- 7) Find all peers who have completed the whole given block of tasks and the completion date of the last task
CREATE OR REPLACE PROCEDURE peers_completed_block (IN cursor REFCURSOR, block_name VARCHAR) AS $$
DECLARE task_count INT := (
        SELECT COUNT(*)
        FROM tasks
        WHERE tasks.title ~ ('^' || block_name || '[0-9]')
    );
BEGIN OPEN cursor FOR WITH peer_complete_tasks AS (
    SELECT DISTINCT ON(checks.peer, checks.task) checks.peer,
        checks.task,
        checks.date_check
    FROM checks
        JOIN p2p ON checks.id = p2p.check_num
        JOIN verter ON checks.id = verter.check_num
    WHERE checks.task ~ ('^' || block_name || '[0-9]')
        AND (
            p2p.check_state = 'Success'
            AND verter.check_state = 'Success'
        )
    ORDER BY checks.peer,
        checks.task,
        checks.date_check DESC
),
uniq_count_tasks AS (
    SELECT peer,
        COUNT(*) AS amount,
        MAX(date_check) AS day
    FROM peer_complete_tasks
    GROUP BY peer
)
SELECT ct.peer,
    TO_CHAR(ct.day, 'dd.mm.yyyy') AS day
FROM uniq_count_tasks ct
WHERE amount = task_count
ORDER BY day;
END;
$$ LANGUAGE plpgsql;
CALL peers_completed_block('result_p3_t7', 'DO');
FETCH ALL IN result_p3_t7;
-- 8) Determine which peer each student should go to for a check.
CREATE OR REPLACE PROCEDURE rec_checked_peer (IN cursor REFCURSOR) AS $$ BEGIN OPEN cursor FOR WITH recommended_counts AS (
        SELECT r.recomended_peer,
            COUNT(f.peer1) AS friend_count
        FROM recomendations r
            JOIN friend f ON r.recomended_peer = f.peer2
        GROUP BY r.recomended_peer
    ),
    ranked_recommended AS (
        SELECT r.peer,
            rc.recomended_peer,
            rc.friend_count,
            ROW_NUMBER() OVER (
                PARTITION BY r.peer
                ORDER BY rc.friend_count DESC
            ) AS rank
        FROM recomendations r
            JOIN recommended_counts rc ON r.recomended_peer = rc.recomended_peer
    )
SELECT p.nickname AS Peer,
    rr.recomended_peer AS RecommendedPeer
FROM peers p
    JOIN ranked_recommended rr ON p.nickname = rr.peer
WHERE rr.rank = 1
ORDER BY p.nickname;
END;
$$ LANGUAGE plpgsql;
CALL rec_checked_peer('result_p3_t8');
FETCH ALL IN result_p3_t8;
-- 9) Determine the percentage of peers who:
CREATE OR REPLACE PROCEDURE percent_of_peers (
        IN cursor REFCURSOR,
        block_1 VARCHAR,
        block_2 VARCHAR
    ) AS $$ BEGIN OPEN cursor FOR WITH all_peers_blocks AS (
        SELECT p.nickname,
            c.task
        FROM peers p
            LEFT JOIN checks c ON p.nickname = c.peer
    ),
    peers_b1 AS (
        SELECT DISTINCT ON (a.nickname) nickname
        FROM all_peers_blocks a
        WHERE a.task ~ ('^' || block_1 || '[0-9]')
    ),
    peers_b2 AS (
        SELECT DISTINCT ON (a.nickname) nickname
        FROM all_peers_blocks a
        WHERE a.task ~ ('^' || block_2 || '[0-9]')
    ),
    only_b2 AS(
        SELECT COUNT(b21.nickname) AS StartedBlock2
        FROM (
                SELECT b2.nickname
                FROM peers_b2 b2
                EXCEPT
                SELECT b1.nickname
                FROM peers_b1 b1
            ) AS b21
    ),
    only_b1 AS(
        SELECT COUNT(b12.nickname) AS StartedBlock1
        FROM (
                SELECT b1.nickname
                FROM peers_b1 b1
                EXCEPT
                SELECT b2.nickname
                FROM peers_b2 b2
            ) AS b12
    ),
    both_blocks AS (
        SELECT COUNT(bb.nickname) AS StartedBothBlocks
        FROM (
                SELECT b1.nickname
                FROM peers_b1 b1
                    JOIN peers_b2 b2 ON b2.nickname = b1.nickname
            ) AS bb
    )
SELECT ROUND(
        CAST(b1.StartedBlock1 AS NUMERIC) / CAST(p.amount AS NUMERIC) * 100,
        0
    ) AS "StartedBlock1",
    ROUND(
        CAST(b2.StartedBlock2 AS NUMERIC) / CAST(p.amount AS NUMERIC) * 100,
        0
    ) AS "StartedBlock2",
    ROUND(
        CAST(bb.StartedBothBlocks AS NUMERIC) / CAST(p.amount AS NUMERIC) * 100,
        0
    ) AS "StartedBothBlocks",
    ROUND(
        CAST(p_null.amount AS NUMERIC) / CAST(p.amount AS NUMERIC) * 100,
        0
    ) AS "DidntStartAnyBlock"
FROM (
        SELECT COUNT(peers.nickname) AS amount
        FROM peers
    ) AS p,
    (
        SELECT COUNT(ap.nickname) AS amount
        FROM all_peers_blocks ap
        WHERE task IS NULL
    ) AS p_null,
    only_b1 b1,
    only_b2 b2,
    both_blocks bb;
END;
$$ LANGUAGE plpgsql;
CALL percent_of_peers('result_p3_t9', 'DO', 'C');
FETCH ALL IN result_p3_t9;
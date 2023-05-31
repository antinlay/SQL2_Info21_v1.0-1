-- Write a function that returns the TransferredPoints table in a more human-readable form
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
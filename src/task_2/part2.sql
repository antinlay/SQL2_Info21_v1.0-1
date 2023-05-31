CREATE OR REPLACE PROCEDURE apend_check (
        IN checked_peer VARCHAR,
        IN checking_peer VARCHAR,
        IN task VARCHAR,
        IN check_state,
        IN
    ) LANGUAGE plpgsql AS $$ BEGIN EXECUTE format (
        IF (check_state = 'Success') THEN 'INSERT INTO checks
        VALUES(%L, %L, %L)',
        checked_peer,
        task,
        CURRENT_DATE
    );
ENDIF;
END;
$$;
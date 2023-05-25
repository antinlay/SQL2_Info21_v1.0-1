
CREATE OR REPLACE PROCEDURE p2p_check_add (
    checking_peer CHAR(50),
    accesser_peer CHAR(50),
    task_name CHAR(50),
    status INT,
    time_ TIME
)
AS $$
DECLARE
    max_checks_id INT;
    max_p2p_id INT;
	status_check INT;
BEGIN
    SELECT COALESCE(MAX(id), 0) INTO max_checks_id FROM checks;
    SELECT COALESCE(MAX(id), 0) INTO max_p2p_id FROM p2p;
    SELECT COUNT(p2p.state_) INTO status_check FROM p2p, checks
		WHERE ChekingPeer = accesser_peer AND
		p2p.check_ = checks.id AND
		checks.peer = checking_peer AND
		task_name = checks.task;
    IF status = 1 THEN
		IF MOD(status_check, 2) = 1 THEN
			RAISE NOTICE 'Такая проверка была открыта';
		ELSE
        	INSERT INTO checks (id, peer, task, date) VALUES (max_checks_id + 1, checking_peer, task_name, CURRENT_DATE);
        	INSERT INTO p2p VALUES (max_p2p_id + 1, max_checks_id + 1, accesser_peer, status, time_);
		END IF;
	ELSE
		IF MOD(status_check, 2) = 1 THEN
			INSERT INTO p2p VALUES (max_p2p_id + 1, max_checks_id, accesser_peer, status, time_);
		ELSE
			RAISE NOTICE 'Такая проверка не была открыта';
		END IF;	
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE verter_check_add(checking_peer CHAR(50), task_name CHAR(80), status INT, time_ TIME)
AS $$
DECLARE
	max_varter_id INT;
	max_p2p_id INT;
	status_check INT;
	p2p_check_id INT;
BEGIN
	SELECT COALESCE(MAX(id), 0) INTO max_varter_id FROM verter;
	SELECT checks.id INTO max_p2p_id FROM p2p, checks
	WHERE p2p.check_ = checks.id AND
		checks.peer = checking_peer AND
		task_name = checks.task AND
		p2p.state_ = 2
		ORDER BY checks.date DESC;
	SELECT p2p.check_ INTO p2p_check_id FROM checks, p2p
 	WHERE p2p.check_ = checks.id AND
		checks.peer = checking_peer AND
		task_name = checks.task;
	SELECT COUNT(verter.id) INTO status_check FROM verter
	WHERE verter.check_ = p2p_check_id;
	IF status = 1 THEN
		IF max_p2p_id IS NULL OR MOD(status_check, 2) = 1 THEN
			RAISE NOTICE 'Такая проверка не была открыта';
		ELSE
			INSERT INTO verter VALUES (max_varter_id + 1, max_p2p_id, status, time_);
		END IF;
	ELSE
		IF MOD(status_check, 2) = 1 THEN
			INSERT INTO verter VALUES (max_varter_id + 1, max_p2p_id, status, time_);
		ELSE
			RAISE NOTICE 'Такая проверка не была открыта';
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_aft_insert_p2p()
    RETURNS TRIGGER AS $$
DECLARE
    checking_peer TEXT;
    accesser_peer TEXT;
BEGIN
    SELECT p2p.chekingpeer INTO accesser_peer FROM p2p
    WHERE p2p.chekingpeer = NEW.chekingpeer;

    SELECT peer INTO checking_peer FROM checks, p2p
    WHERE p2p.check_ = checks.id;

    IF NEW.state_ = 1 THEN
        IF EXISTS (
            SELECT 1 FROM transferredpoints
            WHERE checking_peer = transferredpoints.checkingpeer
                AND accesser_peer = transferredpoints.checkedpeer
        ) THEN
            UPDATE transferredpoints
            SET pointsamount = pointsamount + 1
            WHERE checking_peer = transferredpoints.checkingpeer
                AND accesser_peer = transferredpoints.checkedpeer;
            RETURN NEW;
        ELSE
            INSERT INTO transferredpoints (checkingpeer, checkedpeer, pointsamount)
            VALUES (NEW.checking_peer, checking_peer, 1);
            RETURN NEW;
        END IF;
    END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_fn_aft_insert_p2p
AFTER INSERT ON p2p FOR EACH ROW EXECUTE FUNCTION fn_aft_insert_p2p();

CREATE OR REPLACE FUNCTION fn_xp_add () 
	RETURNS TRIGGER AS $$
DECLARE
	max_xp_task INT;
BEGIN
	SELECT maxxp INTO max_xp_task FROM tasks
	JOIN checks ON checks.task = tasks.title
	JOIN xp ON xp.check_ = checks.id
	WHERE checks.id = NEW.check_;

	IF NOT EXISTS (SELECT 1 FROM checks 
				   JOIN verter ON verter.check_ = checks.id
				   WHERE checks.id = NEW.check_ AND
				   verter.state_ = 2) OR max_xp_task <= NEW.xpamount THEN
				   RAISE EXCEPTION 'Проверка не прошла, либо xp превышает норму %', max_xp_task;
	ELSE
		RAISE NOTICE 'xp успешно добавлено';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_fn_xp_add
BEFORE INSERT ON xp FOR EACH ROW EXECUTE FUNCTION fn_xp_add();


-- Добавление проверок p2p c успехом
-- CALL p2p_check_add('merylpor', 'charisho', 'CPP5_MLP', 1, CURRENT_TIME::TIME);
-- CALL p2p_check_add('merylpor', 'charisho', 'CPP5_MLP', 2, CURRENT_TIME::TIME);


-- Добавление проверки verter с успехом
-- CALL verter_check_add ('merylpor', 'CPP5_MLP', 1, CURRENT_TIME::TIME);
-- CALL verter_check_add ('merylpor', 'CPP5_MLP', 2, CURRENT_TIME::TIME);

-- Добавление xp с препроверкой на валидность статуса вертера и допустимого количества хр
-- Успех
-- INSERT INTO xp VALUES (6, 2, 300);

-- Не успех, в первом случае превышения нормы хр, а во втором случае проваленая проверка вертером
-- INSERT INTO xp VALUES (7, 2, 900);
-- INSERT INTO xp VALUES (6, 5, 300);





























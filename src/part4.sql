-- For this part of the task, you need to create a separate database, in which to create the tables, 
CREATE TABLE IF NOT EXISTS "TableName_1" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableName_2" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableName_3" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableName_4" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableName_5" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableName_6" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "LableName_no" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableFName_no" (id SERIAL PRIMARY KEY, header VARCHAR);
CREATE TABLE IF NOT EXISTS "TableNamCe_no" (id SERIAL PRIMARY KEY, header VARCHAR);
-- functions,
-- TableName_1
CREATE OR REPLACE FUNCTION func_1(
        head VARCHAR default 'Where is my money Lebowski?'
    ) RETURNS void AS $$
INSERT INTO "TableName_1"(header)
VALUES(head);
$$ LANGUAGE SQL;
SELECT func_1();
SELECT *
FROM "TableName_1";
-- TableName_2
CREATE OR REPLACE FUNCTION func_2(
        head VARCHAR default 'Where is my money Lebowski?'
    ) RETURNS void AS $$
INSERT INTO "TableName_2"(header)
VALUES(head);
$$ LANGUAGE SQL;
SELECT func_2();
SELECT *
FROM "TableName_2";
-- TableName_3
CREATE OR REPLACE FUNCTION func_3(
        head VARCHAR default 'Where is my money Lebowski?'
    ) RETURNS void AS $$
INSERT INTO "TableName_3"(header)
VALUES(head);
$$ LANGUAGE SQL;
SELECT func_3();
SELECT *
FROM "TableName_3";
-- procedures,
-- TableName_4
CREATE OR REPLACE PROCEDURE procedure_1(
        head VARCHAR default 'Where is my money Lebowski?'
    ) LANGUAGE plpgsql AS $$ BEGIN EXECUTE format(
        'INSERT INTO "TableName_4"(header)
VALUES(%L)',
        head
    );
END;
$$;
CALL procedure_1();
SELECT *
FROM "TableName_4";
-- TableName_5
CREATE OR REPLACE PROCEDURE procedure_2(
        head VARCHAR default 'Where is my money Lebowski?'
    ) LANGUAGE plpgsql AS $$ BEGIN EXECUTE format(
        'INSERT INTO "TableName_5"(header)
VALUES(%L)',
        head
    );
END;
$$;
CALL procedure_2();
SELECT *
FROM "TableName_5";
-- TableName_6
CREATE OR REPLACE PROCEDURE procedure_3(
        head VARCHAR default 'Where is my money Lebowski?'
    ) LANGUAGE plpgsql AS $$ BEGIN EXECUTE format(
        'INSERT INTO "TableName_6"(header)
VALUES(%L)',
        head
    );
END;
$$;
CALL procedure_3();
SELECT *
FROM "TableName_6";
-- and triggers needed to test the procedures.
CREATE OR REPLACE FUNCTION fnc_handle() RETURNS TRIGGER AS $$ BEGIN IF (TG_OP = 'INSERT') THEN NEW.header = 'Jeff';
RETURN NEW;
ELSIF (TG_OP = 'UPDATE') THEN NEW.header = 'Jeff';
RETURN NEW;
ELSIF (TG_OP = 'DELETE') THEN RETURN OLD;
END IF;
END;
$$ LANGUAGE plpgsql;
-- trigger 1
CREATE OR REPLACE TRIGGER trigger_1 BEFORE
INSERT
    OR
UPDATE
    OR DELETE ON "TableName_1" FOR EACH ROW EXECUTE FUNCTION fnc_handle();
-- 1) Create a stored procedure that, without destroying the database, destroys all those tables in the current database whose names begin with the phrase 'TableName'.
CREATE OR REPLACE PROCEDURE destroy_tables(_prefix text) AS $$
DECLARE loop_record text;
BEGIN FOR loop_record IN
SELECT quote_ident(table_schema) || '.' || quote_ident(table_name)
FROM information_schema.tables
WHERE table_schema LIKE 'public'
    AND table_type = 'BASE TABLE'
    AND table_name LIKE (_prefix || '%') LOOP EXECUTE 'DROP TABLE IF EXISTS ' || loop_record || ' CASCADE';
END LOOP;
END;
$$ LANGUAGE plpgsql;
CALL desctroy_tables('p');
-- GPT FUNCTION !!!!!!
CREATE OR REPLACE PROCEDURE desctroy_tables(IN name_pattern VARCHAR) AS $$
DECLARE loop_record record;
BEGIN FOR loop_record IN
SELECT table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema LIKE 'public' || '%'
    AND table_type = 'BASE TABLE' LOOP EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(loop_record.table_schema) || '.' || quote_ident(loop_record.table_name) || ' CASCADE';
RAISE NOTICE 'Table deleted: %',
quote_ident(loop_record.table_schema) || '.' || quote_ident(loop_record.table_name);
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- 2) Create a stored procedure with an output parameter that outputs a list of names and parameters of all scalar user's SQL functions in the current database. Do not output function names without parameters. The names and the list of parameters must be in one string. The output parameter returns the number of functions found.
CREATE OR REPLACE PROCEDURE pr_part4_task2(
        INOUT rows_count INTEGER,
        IN table_schema_pattern TEXT DEFAULT 'public'
    ) AS $$ BEGIN DROP TABLE IF EXISTS tmp_part4_task2;
CREATE TEMP TABLE tmp_part4_task2 AS
SELECT MAX(routines.routine_name) AS function_name,
    string_agg(
        parameters.parameter_name,
        ', '
        ORDER BY parameters.ordinal_position
    ) AS function_parameters
FROM information_schema.routines
    LEFT JOIN information_schema.parameters ON routines.specific_name = parameters.specific_name
WHERE routines.specific_schema = table_schema_pattern
    AND routine_type = 'FUNCTION'
    AND parameter_name IS NOT NULL
GROUP BY parameters.specific_name -- Группировку делаем не по routine_name
    -- чтобы отобразить все перегрузки с одним именем
ORDER BY function_name;
SELECT COUNT(*)
FROM tmp_part4_task2 INTO rows_count;
END;
$$ LANGUAGE plpgsql;
-- 3) Create a stored procedure with output parameter, which destroys all SQL DML triggers in the current database. The output parameter returns the number of destroyed triggers.
CREATE OR REPLACE PROCEDURE pr_part4_task3(
        INOUT trigger_count INTEGER,
        IN table_schema_pattern TEXT DEFAULT 'public'
    ) AS $$
DECLARE rec record;
BEGIN trigger_count := 0;
FOR rec IN
SELECT quote_ident(trigger_name) || ' ON ' || quote_ident(event_object_table) AS comm_to_drop
FROM information_schema.triggers
WHERE trigger_schema = table_schema_pattern
GROUP BY trigger_name,
    event_object_table LOOP BEGIN trigger_count := trigger_count + 1;
EXECUTE 'DROP TRIGGER ' || rec.comm_to_drop || ';';
EXCEPTION
WHEN OTHERS THEN trigger_count := trigger_count - 1;
END;
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- 4) Create a stored procedure with an input parameter that outputs names and descriptions of object types (only stored procedures and scalar functions) that have a string specified by the procedure parameter.
CREATE OR REPLACE PROCEDURE pr_part4_task4(
        IN search_pattern TEXT,
        IN table_schema_pattern TEXT DEFAULT 'public'
    ) AS $$ BEGIN DROP TABLE IF EXISTS tmp_part4_task4;
CREATE TEMP TABLE tmp_part4_task4 AS
SELECT routine_name AS name,
    routine_type AS type
FROM information_schema.routines
WHERE routines.specific_schema = table_schema_pattern -- ищем заданный паттерн в коде объекта
    AND routine_definition ILIKE '%' || search_pattern || '%' -- Т.к. в задании "на языке SQL", то отсавляем только объекты,
    -- написанные на SQL
    AND routine_body = 'SQL' -- Т.к. в задании "(только хранимых процедур и скалярных функций)",
    -- хотя на самом деле routine_type может принимать только 2 значения
    AND (
        routine_type = 'FUNCTION'
        OR routine_type = 'PROCEDURE'
    )
ORDER BY name;
END;
$$ LANGUAGE plpgsql;
-- 1) Create a stored procedure that, without destroying the database, destroys all those tables in the current database whose names begin with the phrase 'TableName'.
CREATE OR REPLACE FUNCTION destroy_tables(_prefix text) RETURNS void AS $func$
DECLARE loop_record text;
BEGIN FOR loop_record IN
SELECT quote_ident(table_schema) || '.' || quote_ident(table_name)
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
    AND table_name LIKE (_prefix || '%') LOOP EXECUTE 'DROP TABLE ' || loop_record || ' CASCADE';
END LOOP;
END $func$ LANGUAGE plpgsql;
SELECT destroy_tables('p');
-- GPT FUNCTION !!!!!!
CREATE OR REPLACE PROCEDURE desctroy_tables(IN name_pattern VARCHAR) LANGUAGE plpgsql AS $$
DECLARE loop_record record;
BEGIN FOR loop_record IN
SELECT *
FROM information_schema.tables
SELECT table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema LIKE 'public' || '%'
    AND table_type = 'BASE TABLE' LOOP EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(loop_record.table_schema) || '.' || quote_ident(loop_record.table_name) || ' CASCADE';
RAISE NOTIICE 'Table deleted: %',
quote_ident(loop_record.table_schema) || '.' || quote_ident(loop_record.table_name);
END LOOP;
END;
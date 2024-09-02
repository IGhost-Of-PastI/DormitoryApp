-- PROCEDURE: public.update_table(text, text, integer, json)

-- DROP PROCEDURE IF EXISTS public.update_table(text, text, integer, json);

CREATE OR REPLACE PROCEDURE public.update_table(
	IN update_table_name text,
	IN id_column text,
	IN id_value integer,
	IN update_columns json,
	IN ID_Staff bigint)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    update_column_name TEXT;
    column_value TEXT;
    update_query TEXT;
BEGIN
    EXECUTE format(
        'WITH select_old AS (
            SELECT *
            FROM public."%I"
            WHERE %I = %L
        ),
        update_new AS (
            UPDATE public."%I"
            SET %s
            WHERE %I = %L
            RETURNING *
        )
         INSERT INTO public."Logs" ("Action_Timestamp", "ID_Staff", "ID_Action_Type", "Action_Description")
                SELECT NOW(), %L , 1, json_agg(t.json_data)
                FROM (
                    SELECT row_to_json(select1Main)::json AS json_data FROM select1Main
                    UNION ALL
                    SELECT row_to_json(updatedMain)::json AS json_data FROM updatedMain
                ) t;',
        update_table_name, id_column, id_value, 
		update_table_name,(SELECT string_agg(format('%I = %L', "key", "value"), ', ') FROM json_each_text(update_columns)),id_column, id_value,
		
    );
END;
$BODY$;
ALTER PROCEDURE public.update_table(text, text, integer, json)
    OWNER TO postgres;

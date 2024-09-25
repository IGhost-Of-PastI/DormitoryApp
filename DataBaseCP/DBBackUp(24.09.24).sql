toc.dat                                                                                             0000600 0004000 0002000 00000142332 14674555553 0014467 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   7                    |         	   Dormitory    16.4    16.4 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         �           1262    34806 	   Dormitory    DATABASE     �   CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';
    DROP DATABASE "Dormitory";
                postgres    false                     3079    34807    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false         �           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    2         +           1255    35051    check_room_capacity()    FUNCTION     �  CREATE FUNCTION public.check_room_capacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_occupancy INTEGER;
    max_capacity INTEGER;
BEGIN
    -- Get the current number of students in the room
    SELECT COUNT(*) INTO current_occupancy
    FROM public."сheck_ins"
    WHERE id_room = NEW.id_room AND check_out_timestamp IS NULL;

    -- Get the maximum capacity of the room
    SELECT number_of_seats INTO max_capacity
    FROM public.rooms
    WHERE id = NEW.id_room;

    -- Check if adding the new student would exceed the room's capacity
    IF current_occupancy >= max_capacity THEN
        RAISE EXCEPTION 'Room capacity exceeded. Cannot check in more students.';
    END IF;

    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.check_room_capacity();
       public          postgres    false         *           1255    35043 <   check_user_credentials(character varying, character varying)    FUNCTION     f  CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name character varying, patronymic character varying, id bigint, dormitoryname character varying, rolename character varying, acceses json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.surname, s.name, s.patronymic, s.id,d.name as dormitoryname,j.name as rolename,j.acceses 
    FROM staffs s
	Join jobs j
	on s.id_job = j.id
	Join dormitory d
	on s.id_dormitory = d."id" 
    WHERE login = p_username AND "password" = MD5(p_password);
END;
$$;
 i   DROP FUNCTION public.check_user_credentials(p_username character varying, p_password character varying);
       public          postgres    false         !           1255    34845 %   compare_jsons(json, json, text, text)    FUNCTION       CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    obj1 jsonb;
    obj2 jsonb;
	obj2_value text;
	
	json_key text;
	json_value text;
	
	temporary_json jsonb;
	json_array jsonb:='[]'::jsonb;
	
    key_value text;

BEGIN
    
	FOR obj1 IN SELECT * FROM jsonb_array_elements(json1::jsonb) LOOP
        key_value := obj1->>key_column;
        obj2 := (SELECT value FROM jsonb_array_elements(json2::jsonb) value WHERE value->>key_column = key_value::text);
        
        IF obj2 IS NOT NULL THEN
		temporary_json := '{}'::jsonb;
            FOR json_key, json_value IN SELECT key, value FROM jsonb_each(obj1) LOOP
				IF obj1->>json_key <> obj2->>json_key THEN
					obj2_value := obj2->>json_key;
                    temporary_json:= jsonb_insert(temporary_json,string_to_array(json_key,','), to_jsonb(obj1->>json_key || ' -> ' || obj2_value));
                ELSE
					temporary_json:= jsonb_insert(temporary_json,string_to_array(json_key,','),json_value::jsonb);
				END IF;
				
            END LOOP;
			json_array:= jsonb_insert(json_array, '{99999}',temporary_json);
        END IF;
    END LOOP;
    
    RETURN jsonb_build_object('table', table_name, 'changes', json_array)::json;
END;
$$;
 ^   DROP FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text);
       public          postgres    false         "           1255    34846 +   delete_from_table(text, text, text, bigint) 	   PROCEDURE     f  CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    delete_query TEXT;
	deletedRecord RECORD;
	deleteJson json;
BEGIN
    delete_query := 'DELETE FROM public.' || quote_ident(delete_table_name) || ' WHERE ' || quote_ident(id_column) || ' = ' || id_value || ' RETURNING *';
    EXECUTE delete_query into deletedRecord;
	deleteJson:= json_agg(row_to_json(deletedRecord))::json;
	CALL insert_into_logs(3,ID_Staff,jsonb_build_object('table', delete_table_name, 'deleted', deleteJson)::json);
END;
$$;
 }   DROP PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint);
       public          postgres    false         #           1255    34847 -   delete_from_tablesf(text, text, text, bigint)    FUNCTION     �   CREATE FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL delete_from_table(delete_table_name, id_column, id_value, id_staff);
END;
$$;
 r   DROP FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint);
       public          postgres    false         $           1255    34848    get_all_tables()    FUNCTION     
  CREATE FUNCTION public.get_all_tables() RETURNS TABLE(table_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.table_name::text 
	FROM information_schema.tables t
	WHERE t.table_schema = 'public'
	AND t.table_type = 'BASE TABLE';
END;
$$;
 '   DROP FUNCTION public.get_all_tables();
       public          postgres    false         %           1255    34849    get_all_views()    FUNCTION       CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT table_name::text 
    FROM information_schema.views
    WHERE table_schema NOT IN ('information_schema', 'pg_catalog');
END;
$$;
 &   DROP FUNCTION public.get_all_views();
       public          postgres    false                    1255    34850    get_column_info(text, text)    FUNCTION     �  CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg_type.typname::TEXT AS column_type,
        CASE
            WHEN pg_type.typname = 'varchar' THEN pg_attribute.atttypmod - 4
            ELSE NULL
        END AS character_maximum_length,
        NOT pg_attribute.attnotnull AS is_nullable
    FROM 
        pg_attribute
    JOIN 
        pg_class ON pg_class.oid = pg_attribute.attrelid
    JOIN 
        pg_type ON pg_type.oid = pg_attribute.atttypid
    WHERE 
        pg_class.relname = table_name AND pg_attribute.attname = column_name;
END;
$$;
 I   DROP FUNCTION public.get_column_info(table_name text, column_name text);
       public          postgres    false                    1255    34851    get_foreign_keys(text)    FUNCTION       CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        tc.constraint_name::text,
        kcu.column_name::text,
        ccu.table_name::text AS referenced_table,
        ccu.column_name::text AS referenced_column
    FROM
        information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
    WHERE
        tc.constraint_type = 'FOREIGN KEY' AND
        tc.table_name = p_table_name;
END;
$$;
 :   DROP FUNCTION public.get_foreign_keys(p_table_name text);
       public          postgres    false                    1255    34852    get_primary_key_column(text)    FUNCTION     k  CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    pk_column text;
BEGIN
    EXECUTE format('SELECT kcu.column_name::text
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                    WHERE tc.constraint_type = ''PRIMARY KEY''
                    AND tc.table_name = %L', table_name)
    INTO pk_column;
    
    RETURN pk_column;
END;
$$;
 >   DROP FUNCTION public.get_primary_key_column(table_name text);
       public          postgres    false                    1255    34853    get_table_columns(text)    FUNCTION       CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT c."column_name"::text
    FROM information_schema.columns c
    WHERE c."table_name" = p_table_name;
END;
$$;
 ;   DROP FUNCTION public.get_table_columns(p_table_name text);
       public          postgres    false                    1255    34854    getcolumnindex(text, text)    FUNCTION     =  CREATE FUNCTION public.getcolumnindex(tablename text, tablecolumn text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
Declare
columnindex int;
BEGIN
    SELECT ordinal_position
	into columnindex
FROM information_schema.columns
WHERE table_name = tablename AND column_name = tablecolumn;
return columnindex;
END;
$$;
 G   DROP FUNCTION public.getcolumnindex(tablename text, tablecolumn text);
       public          postgres    false                    1255    34855    hash_password()    FUNCTION     �   CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.password := MD5(NEW.password);
    RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false                    1255    34856    hash_password_update()    FUNCTION     �   CREATE FUNCTION public.hash_password_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.password IS DISTINCT FROM OLD.password THEN
        NEW.password := MD5(NEW.password);
    END IF;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.hash_password_update();
       public          postgres    false                    1255    34857 &   insert_into_logs(bigint, bigint, json) 	   PROCEDURE     3  CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO logs (action_timestamp, id_action_type, id_staff, action_description) 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;
 p   DROP PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json);
       public          postgres    false         &           1255    34858 %   insert_into_table(bigint, text, json) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    "column_name" Text;
	"column_value" text;
	column_names TEXT;
    column_values TEXT;
    insert_query TEXT;
	inserted_row RECORD;
	logJson json;
BEGIN
   column_names := '';
column_values := '';

FOR column_name, column_value IN
    SELECT key, value
    FROM json_each_text(insert_columns)
LOOP
    column_names := column_names || quote_ident(column_name) || ', ';
    column_values := column_values || quote_literal(column_value) || ', ';
END LOOP;

-- Удаляем последнюю запятую и пробел
column_names := left(column_names, length(column_names) - 2);
column_values := left(column_values, length(column_values) - 2);

insert_query := 'INSERT INTO public.' || quote_ident(insert_table_name) || ' (' || column_names || ') VALUES (' || column_values || ') RETURNING *';

	EXECUTE insert_query into inserted_row;
	SELECT json_agg(t.json_data)
INTO logJson
        FROM (
            SELECT row_to_json(inserted_row)::json AS json_data
        ) t;
	 CALL insert_into_logs(2, staff_id, jsonb_build_object('table', insert_table_name, 'inserted', logJson)::json);        
END;
$$;
 p   DROP PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json);
       public          postgres    false         '           1255    34859 %   insert_into_tablesf(text, text, text)    FUNCTION     �   CREATE FUNCTION public.insert_into_tablesf(id text, table_name text, string text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, string::json);
END;
$$;
 Q   DROP FUNCTION public.insert_into_tablesf(id text, table_name text, string text);
       public          postgres    false         (           1255    34860 ,   update_table(text, text, text, json, bigint) 	   PROCEDURE     �  CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    update_column_name TEXT;
    column_value TEXT;
    update_query TEXT;
	select_query text;
	
	updatedRecord RECORD;
	updatedJson json;
	selectedRecord RECORD;
	selectedJson json;
	
	finaljson json;
	
BEGIN
    update_query := 'UPDATE public."' || update_table_name || '" SET ';
    
    FOR update_column_name, column_value IN
        SELECT "key", "value"
        FROM json_each_text(update_columns)
    LOOP
        update_query := update_query || quote_ident(update_column_name) || ' = ' || quote_literal(column_value) || ', ';
    END LOOP;
    
    -- Удаляем последнюю запятую и пробел
    update_query := left(update_query, length(update_query) - 2);
    
	select_query := 'Select * from '||' public."'||update_table_name||'" WHERE "' || id_column || '" = ' || id_value;
    update_query := update_query || ' WHERE "' || id_column || '" = ' || id_value || ' RETURNING *';
	
	
	EXECUTE select_query into selectedRecord;
    EXECUTE update_query into updatedRecord;
	
	updatedJson:= json_agg(row_to_json(updatedRecord))::json;
	selectedJson:= json_agg(row_to_json(selectedRecord))::json;
	
	Select compare_jsons(selectedJson,updatedJson,update_table_name,id_column) into finaljson;
	
	CALL insert_into_logs(1,ID_Staff, finaljson);
END;
$$;
 �   DROP PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint);
       public          postgres    false         )           1255    34861 ,   update_tablesf(text, text, text, text, text)    FUNCTION        CREATE FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL update_table(update_table_name,id_column,id_value ,update_columns::json,id_staff::bigint);
END;
$$;
 �   DROP FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text);
       public          postgres    false         �            1259    34862 
   сheck_ins    TABLE     �   CREATE TABLE public."сheck_ins" (
    id bigint NOT NULL,
    id_stud bigint,
    id_room bigint,
    check_in_timestamp timestamp with time zone
);
     DROP TABLE public."сheck_ins";
       public         heap    postgres    false         �            1259    34865    Check_In_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Check_In_ID_seq";
       public          postgres    false    221         �           0    0    Check_In_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."сheck_ins".id;
          public          postgres    false    222         �            1259    34866 	   dormitory    TABLE     �   CREATE TABLE public.dormitory (
    id bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);
    DROP TABLE public.dormitory;
       public         heap    postgres    false         �            1259    34869    Dormitory_ID_seq    SEQUENCE     {   CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public."Dormitory_ID_seq";
       public          postgres    false    223         �           0    0    Dormitory_ID_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public.dormitory.id;
          public          postgres    false    224         �            1259    34870    jobs    TABLE     }   CREATE TABLE public.jobs (
    id bigint NOT NULL,
    name character varying(50),
    acceses json,
    description text
);
    DROP TABLE public.jobs;
       public         heap    postgres    false         �            1259    34875 
   Job_ID_seq    SEQUENCE     u   CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public."Job_ID_seq";
       public          postgres    false    225         �           0    0 
   Job_ID_seq    SEQUENCE OWNED BY     <   ALTER SEQUENCE public."Job_ID_seq" OWNED BY public.jobs.id;
          public          postgres    false    226         �            1259    34876    logs_action_types    TABLE     x   CREATE TABLE public.logs_action_types (
    id bigint NOT NULL,
    name character varying(50),
    description text
);
 %   DROP TABLE public.logs_action_types;
       public         heap    postgres    false         �            1259    34881    Logs_Action_Types_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Logs_Action_Types_ID_seq";
       public          postgres    false    227         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public.logs_action_types.id;
          public          postgres    false    228         �            1259    34882    logs    TABLE     �   CREATE TABLE public.logs (
    id bigint NOT NULL,
    action_timestamp timestamp with time zone,
    id_action_type bigint,
    id_staff bigint,
    action_description json
);
    DROP TABLE public.logs;
       public         heap    postgres    false         �            1259    34887    Logs_ID_seq    SEQUENCE     v   CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."Logs_ID_seq";
       public          postgres    false    229         �           0    0    Logs_ID_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public.logs.id;
          public          postgres    false    230         �            1259    34888    rooms    TABLE     �   CREATE TABLE public.rooms (
    id bigint NOT NULL,
    room_number bigint,
    floor integer,
    number_of_seats integer,
    id_dormitory bigint
);
    DROP TABLE public.rooms;
       public         heap    postgres    false         �            1259    34891    Rooms_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Rooms_ID_seq";
       public          postgres    false    231         �           0    0    Rooms_ID_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public.rooms.id;
          public          postgres    false    232         �            1259    34892    specialties    TABLE     r   CREATE TABLE public.specialties (
    id_spec bigint NOT NULL,
    name character varying(50),
    "desc" text
);
    DROP TABLE public.specialties;
       public         heap    postgres    false         �            1259    34897    Specialties_ID_Spec_seq    SEQUENCE     �   CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Specialties_ID_Spec_seq";
       public          postgres    false    233         �           0    0    Specialties_ID_Spec_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public.specialties.id_spec;
          public          postgres    false    234         �            1259    34898    staffs    TABLE     <  CREATE TABLE public.staffs (
    id bigint NOT NULL,
    surname character varying(50),
    name character varying(50),
    patronymic character varying(50),
    id_job bigint,
    contact_number character varying(20),
    id_dormitory bigint,
    login character varying(50),
    password character varying(255)
);
    DROP TABLE public.staffs;
       public         heap    postgres    false         �            1259    34901    Staff_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Staff_ID_seq";
       public          postgres    false    235         �           0    0    Staff_ID_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public.staffs.id;
          public          postgres    false    236         �            1259    34902    students    TABLE     T  CREATE TABLE public.students (
    id bigint NOT NULL,
    surname character varying(50),
    name character varying(50),
    patronymic character varying(50),
    birth_date date,
    sex boolean,
    contact_number character varying(20),
    email character varying(50),
    id_uni bigint,
    id_speci bigint,
    id_dormitory bigint
);
    DROP TABLE public.students;
       public         heap    postgres    false         �            1259    34905    Students_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Students_ID_seq";
       public          postgres    false    237         �           0    0    Students_ID_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."Students_ID_seq" OWNED BY public.students.id;
          public          postgres    false    238         �            1259    34906    universities    TABLE     �   CREATE TABLE public.universities (
    id_uni bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);
     DROP TABLE public.universities;
       public         heap    postgres    false         �            1259    34909    Universities_ID_Uni_seq    SEQUENCE     �   CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Universities_ID_Uni_seq";
       public          postgres    false    239         �           0    0    Universities_ID_Uni_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public.universities.id_uni;
          public          postgres    false    240         �            1259    34910    visits    TABLE     �   CREATE TABLE public.visits (
    id bigint NOT NULL,
    id_stud bigint,
    date_time_entered timestamp with time zone,
    date_time_leaved timestamp with time zone
);
    DROP TABLE public.visits;
       public         heap    postgres    false         �            1259    34913    Visits_ID_seq    SEQUENCE     x   CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Visits_ID_seq";
       public          postgres    false    241         �           0    0    Visits_ID_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public.visits.id;
          public          postgres    false    242         �            1259    35046    check_ins_details    VIEW     �  CREATE VIEW public.check_ins_details AS
 SELECT ci.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    r.room_number AS "Room_Number",
    ci.check_in_timestamp AS "Check_In_Timestamp",
    d.name AS "Dormitory_Name"
   FROM (((public."сheck_ins" ci
     JOIN public.rooms r ON ((ci.id_room = r.id)))
     JOIN public.students s ON ((ci.id_stud = s.id)))
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));
 $   DROP VIEW public.check_ins_details;
       public          postgres    false    221    221    221    221    223    223    231    231    231    237    237    237    237         �            1259    34919    logs_details    VIEW     o  CREATE VIEW public.logs_details AS
 SELECT l.id AS "ID",
    l.action_timestamp AS "Action_Timestamp",
    lat.name AS "Action_Type",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic"
   FROM ((public.logs l
     JOIN public.logs_action_types lat ON ((l.id_action_type = lat.id)))
     JOIN public.staffs s ON ((s.id = l.id_staff)));
    DROP VIEW public.logs_details;
       public          postgres    false    235    235    235    235    229    229    229    229    227    227         �            1259    34923    rooms_details    VIEW       CREATE VIEW public.rooms_details AS
 SELECT r.id AS "ID",
    r.room_number AS "Room_Number",
    r.floor AS "Floor",
    r.number_of_seats AS "Number_Of_Seats",
    d.name AS "Dormitory_Name"
   FROM (public.rooms r
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));
     DROP VIEW public.rooms_details;
       public          postgres    false    231    231    231    231    231    223    223         �            1259    34927    staffs_details    VIEW     x  CREATE VIEW public.staffs_details AS
 SELECT s.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    j.name AS "Job_Name",
    s.contact_number AS "Contact_Number",
    d.name AS "Dormitory_Name"
   FROM ((public.staffs s
     JOIN public.jobs j ON ((s.id_job = j.id)))
     JOIN public.dormitory d ON ((d.id = s.id_dormitory)));
 !   DROP VIEW public.staffs_details;
       public          postgres    false    235    235    235    235    235    235    223    223    225    225    235         �            1259    34931    student_details    VIEW     @  CREATE VIEW public.student_details AS
 SELECT s.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    s.birth_date AS "Birth_Date",
    s.sex AS "Sex",
    s.contact_number AS "Contact_Number",
    s.email AS "Email",
    u.name AS "University_Name",
    d.name AS "Dormitory_Name",
    sp.name AS "Specialties_Name"
   FROM (((public.students s
     JOIN public.universities u ON ((s.id_uni = u.id_uni)))
     JOIN public.dormitory d ON ((s.id_dormitory = d.id)))
     JOIN public.specialties sp ON ((s.id_speci = sp.id_spec)));
 "   DROP VIEW public.student_details;
       public          postgres    false    237    233    223    223    237    237    237    237    237    237    233    237    237    237    237    239    239         �            1259    34936    visits_details    VIEW     ;  CREATE VIEW public.visits_details AS
 SELECT v.id AS "ID",
    v.date_time_entered AS "Date_Time_Entered",
    v.date_time_leaved AS "Date_Time_Leaved",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic"
   FROM (public.visits v
     JOIN public.students s ON ((v.id_stud = s.id)));
 !   DROP VIEW public.visits_details;
       public          postgres    false    237    241    241    241    237    237    241    237         �           2604    34940    dormitory id    DEFAULT     n   ALTER TABLE ONLY public.dormitory ALTER COLUMN id SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);
 ;   ALTER TABLE public.dormitory ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223         �           2604    34941    jobs id    DEFAULT     c   ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public."Job_ID_seq"'::regclass);
 6   ALTER TABLE public.jobs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225         �           2604    34942    logs id    DEFAULT     d   ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);
 6   ALTER TABLE public.logs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229         �           2604    34943    logs_action_types id    DEFAULT     ~   ALTER TABLE ONLY public.logs_action_types ALTER COLUMN id SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);
 C   ALTER TABLE public.logs_action_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227         �           2604    34944    rooms id    DEFAULT     f   ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);
 7   ALTER TABLE public.rooms ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231         �           2604    34945    specialties id_spec    DEFAULT     |   ALTER TABLE ONLY public.specialties ALTER COLUMN id_spec SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);
 B   ALTER TABLE public.specialties ALTER COLUMN id_spec DROP DEFAULT;
       public          postgres    false    234    233         �           2604    34946 	   staffs id    DEFAULT     g   ALTER TABLE ONLY public.staffs ALTER COLUMN id SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);
 8   ALTER TABLE public.staffs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    236    235         �           2604    34947    students id    DEFAULT     l   ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public."Students_ID_seq"'::regclass);
 :   ALTER TABLE public.students ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    238    237         �           2604    34948    universities id_uni    DEFAULT     |   ALTER TABLE ONLY public.universities ALTER COLUMN id_uni SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);
 B   ALTER TABLE public.universities ALTER COLUMN id_uni DROP DEFAULT;
       public          postgres    false    240    239         �           2604    34949 	   visits id    DEFAULT     h   ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);
 8   ALTER TABLE public.visits ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    242    241         �           2604    34950    сheck_ins id    DEFAULT     p   ALTER TABLE ONLY public."сheck_ins" ALTER COLUMN id SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);
 >   ALTER TABLE public."сheck_ins" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221         z          0    34866 	   dormitory 
   TABLE DATA           F   COPY public.dormitory (id, name, address, contact_number) FROM stdin;
    public          postgres    false    223       4986.dat |          0    34870    jobs 
   TABLE DATA           >   COPY public.jobs (id, name, acceses, description) FROM stdin;
    public          postgres    false    225       4988.dat �          0    34882    logs 
   TABLE DATA           b   COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM stdin;
    public          postgres    false    229       4992.dat ~          0    34876    logs_action_types 
   TABLE DATA           B   COPY public.logs_action_types (id, name, description) FROM stdin;
    public          postgres    false    227       4990.dat �          0    34888    rooms 
   TABLE DATA           V   COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM stdin;
    public          postgres    false    231       4994.dat �          0    34892    specialties 
   TABLE DATA           <   COPY public.specialties (id_spec, name, "desc") FROM stdin;
    public          postgres    false    233       4996.dat �          0    34898    staffs 
   TABLE DATA           v   COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM stdin;
    public          postgres    false    235       4998.dat �          0    34902    students 
   TABLE DATA           �   COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM stdin;
    public          postgres    false    237       5000.dat �          0    34906    universities 
   TABLE DATA           M   COPY public.universities (id_uni, name, address, contact_number) FROM stdin;
    public          postgres    false    239       5002.dat �          0    34910    visits 
   TABLE DATA           R   COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM stdin;
    public          postgres    false    241       5004.dat x          0    34862 
   сheck_ins 
   TABLE DATA           P   COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp) FROM stdin;
    public          postgres    false    221       4984.dat �           0    0    Check_In_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);
          public          postgres    false    222         �           0    0    Dormitory_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, true);
          public          postgres    false    224         �           0    0 
   Job_ID_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public."Job_ID_seq"', 5, true);
          public          postgres    false    226         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);
          public          postgres    false    228         �           0    0    Logs_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Logs_ID_seq"', 83, true);
          public          postgres    false    230         �           0    0    Rooms_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);
          public          postgres    false    232         �           0    0    Specialties_ID_Spec_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 50, true);
          public          postgres    false    234         �           0    0    Staff_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Staff_ID_seq"', 14, true);
          public          postgres    false    236         �           0    0    Students_ID_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."Students_ID_seq"', 1, true);
          public          postgres    false    238         �           0    0    Universities_ID_Uni_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 2, true);
          public          postgres    false    240         �           0    0    Visits_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);
          public          postgres    false    242         �           2606    34952    сheck_ins Check_Ins_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY (id);
 G   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "Check_Ins_pkey";
       public            postgres    false    221         �           2606    34954    dormitory Dormitory_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.dormitory
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.dormitory DROP CONSTRAINT "Dormitory_pkey";
       public            postgres    false    223         �           2606    34956    jobs Job_pkey 
   CONSTRAINT     M   ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY (id);
 9   ALTER TABLE ONLY public.jobs DROP CONSTRAINT "Job_pkey";
       public            postgres    false    225         �           2606    34958 (   logs_action_types Logs_Action_Types_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.logs_action_types
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.logs_action_types DROP CONSTRAINT "Logs_Action_Types_pkey";
       public            postgres    false    227         �           2606    34960    logs Logs_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.logs DROP CONSTRAINT "Logs_pkey";
       public            postgres    false    229         �           2606    34962    rooms Rooms_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.rooms DROP CONSTRAINT "Rooms_pkey";
       public            postgres    false    231         �           2606    34964    specialties Specialties_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY (id_spec);
 H   ALTER TABLE ONLY public.specialties DROP CONSTRAINT "Specialties_pkey";
       public            postgres    false    233         �           2606    34966    staffs Staff_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "Staff_pkey";
       public            postgres    false    235         �           2606    34968    students Students_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.students DROP CONSTRAINT "Students_pkey";
       public            postgres    false    237         �           2606    34970    universities Universities_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.universities
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY (id_uni);
 J   ALTER TABLE ONLY public.universities DROP CONSTRAINT "Universities_pkey";
       public            postgres    false    239         �           2606    34972    visits Visits_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.visits DROP CONSTRAINT "Visits_pkey";
       public            postgres    false    241         �           2606    35056 
   rooms uniq 
   CONSTRAINT     L   ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT uniq UNIQUE (room_number);
 4   ALTER TABLE ONLY public.rooms DROP CONSTRAINT uniq;
       public            postgres    false    231         �           2606    35058    staffs uniqLogin 
   CONSTRAINT     N   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "uniqLogin" UNIQUE (login);
 <   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "uniqLogin";
       public            postgres    false    235         �           2606    35054    specialties uniqName 
   CONSTRAINT     Q   ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT "uniqName" UNIQUE (name);
 @   ALTER TABLE ONLY public.specialties DROP CONSTRAINT "uniqName";
       public            postgres    false    233         �           2606    35045    сheck_ins uniqstud 
   CONSTRAINT     S   ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT uniqstud UNIQUE (id_stud);
 ?   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT uniqstud;
       public            postgres    false    221         �           1259    35031    index_id    INDEX     <   CREATE INDEX index_id ON public.dormitory USING btree (id);
    DROP INDEX public.index_id;
       public            postgres    false    223         �           1259    35041    index_idcheck_ins    INDEX     H   CREATE INDEX index_idcheck_ins ON public."сheck_ins" USING btree (id);
 %   DROP INDEX public.index_idcheck_ins;
       public            postgres    false    221         �           1259    35032    index_idjobs    INDEX     ;   CREATE INDEX index_idjobs ON public.jobs USING btree (id);
     DROP INDEX public.index_idjobs;
       public            postgres    false    225         �           1259    35033    index_idlogs    INDEX     ;   CREATE INDEX index_idlogs ON public.logs USING btree (id);
     DROP INDEX public.index_idlogs;
       public            postgres    false    229         �           1259    35034    index_idlogs_a_t    INDEX     L   CREATE INDEX index_idlogs_a_t ON public.logs_action_types USING btree (id);
 $   DROP INDEX public.index_idlogs_a_t;
       public            postgres    false    227         �           1259    35035    index_idrooms    INDEX     =   CREATE INDEX index_idrooms ON public.rooms USING btree (id);
 !   DROP INDEX public.index_idrooms;
       public            postgres    false    231         �           1259    35036    index_idspecialties    INDEX     N   CREATE INDEX index_idspecialties ON public.specialties USING btree (id_spec);
 '   DROP INDEX public.index_idspecialties;
       public            postgres    false    233         �           1259    35037    index_idstaff    INDEX     >   CREATE INDEX index_idstaff ON public.staffs USING btree (id);
 !   DROP INDEX public.index_idstaff;
       public            postgres    false    235         �           1259    35038    index_idstudents    INDEX     C   CREATE INDEX index_idstudents ON public.students USING btree (id);
 $   DROP INDEX public.index_idstudents;
       public            postgres    false    237         �           1259    35039    index_iduniversities    INDEX     O   CREATE INDEX index_iduniversities ON public.universities USING btree (id_uni);
 (   DROP INDEX public.index_iduniversities;
       public            postgres    false    239         �           1259    35040    index_idvisits    INDEX     ?   CREATE INDEX index_idvisits ON public.visits USING btree (id);
 "   DROP INDEX public.index_idvisits;
       public            postgres    false    241         �           2620    34973 "   staffs before_insert_hash_password    TRIGGER     �   CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 ;   DROP TRIGGER before_insert_hash_password ON public.staffs;
       public          postgres    false    276    235         �           2620    34974 "   staffs before_update_hash_password    TRIGGER     �   CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();
 ;   DROP TRIGGER before_update_hash_password ON public.staffs;
       public          postgres    false    235    274         �           2620    35052 &   сheck_ins check_room_capacity_trigger    TRIGGER     �   CREATE TRIGGER check_room_capacity_trigger BEFORE INSERT OR UPDATE ON public."сheck_ins" FOR EACH ROW EXECUTE FUNCTION public.check_room_capacity();
 A   DROP TRIGGER check_room_capacity_trigger ON public."сheck_ins";
       public          postgres    false    221    299         �           2606    34975    logs FK_Action    FK CONSTRAINT     �   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Action" FOREIGN KEY (id_action_type) REFERENCES public.logs_action_types(id) NOT VALID;
 :   ALTER TABLE ONLY public.logs DROP CONSTRAINT "FK_Action";
       public          postgres    false    227    229    4792         �           2606    34980    students FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 A   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    237    4786         �           2606    34985    staffs FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 ?   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    235    4786         �           2606    34990    rooms FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 >   ALTER TABLE ONLY public.rooms DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    4786    231         �           2606    34995    staffs FK_Jobs    FK CONSTRAINT     w   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY (id_job) REFERENCES public.jobs(id) NOT VALID;
 :   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "FK_Jobs";
       public          postgres    false    225    235    4789         �           2606    35000    сheck_ins FK_Room    FK CONSTRAINT        ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY (id_room) REFERENCES public.rooms(id) NOT VALID;
 @   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "FK_Room";
       public          postgres    false    221    4798    231         �           2606    35005    students FK_Specialites    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY (id_speci) REFERENCES public.specialties(id_spec) NOT VALID;
 C   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_Specialites";
       public          postgres    false    233    4803    237         �           2606    35010    logs FK_Staff    FK CONSTRAINT     z   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY (id_staff) REFERENCES public.staffs(id) NOT VALID;
 9   ALTER TABLE ONLY public.logs DROP CONSTRAINT "FK_Staff";
       public          postgres    false    235    229    4808         �           2606    35015    visits FK_Student    FK CONSTRAINT        ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;
 =   ALTER TABLE ONLY public.visits DROP CONSTRAINT "FK_Student";
       public          postgres    false    4813    241    237         �           2606    35020    сheck_ins FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;
 C   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "FK_Student";
       public          postgres    false    221    4813    237         �           2606    35025    students FK_University    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_University" FOREIGN KEY (id_uni) REFERENCES public.universities(id_uni) NOT VALID;
 B   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_University";
       public          postgres    false    237    239    4816                                                                                                                                                                                                                                                                                                              4986.dat                                                                                            0000600 0004000 0002000 00000000100 14674555553 0014276 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Общежитие 1	УлюРоккоссвоского	
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                4988.dat                                                                                            0000600 0004000 0002000 00000012244 14674555553 0014314 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2	Вахтер	{"UserAccesses":{"ViewLogs":false,"ConfigureBackups":false,"Reports":false},"TableAccesses":[{"TableName":"сheck_ins","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"dormitory","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"students","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"visits","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"logs_action_types","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"rooms","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"jobs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"specialties","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"universities","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"staffs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}}]}	
3	Менеджер по персоналу	{"UserAccesses":{"ViewLogs":false,"ConfigureBackups":false,"Reports":false},"TableAccesses":[{"TableName":"сheck_ins","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"dormitory","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"students","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"visits","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs_action_types","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"rooms","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"jobs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"specialties","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"universities","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"staffs","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"logs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}}]}	
5	Администратор общежития	{"UserAccesses":{"ViewLogs":true,"ConfigureBackups":true,"Reports":true},"TableAccesses":[{"TableName":"сheck_ins","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"dormitory","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"students","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"visits","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs_action_types","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"rooms","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"jobs","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"specialties","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"universities","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"staffs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}}]}	
4	Комендант общежития	{"UserAccesses":{"ViewLogs":false,"ConfigureBackups":false,"Reports":false},"TableAccesses":[{"TableName":"сheck_ins","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"dormitory","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"students","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":true}},{"TableName":"visits","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs_action_types","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"rooms","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"jobs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"specialties","ViewTable":true,"TableActionsAccesses":{"Add":true,"Edit":true,"Delete":false}},{"TableName":"universities","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"staffs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}},{"TableName":"logs","ViewTable":false,"TableActionsAccesses":{"Add":false,"Edit":false,"Delete":false}}]}	description
\.


                                                                                                                                                                                                                                                                                                                                                            4992.dat                                                                                            0000600 0004000 0002000 00000065662 14674555553 0014323 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        31	2024-09-16 02:12:52.835511+03	2	8	[{"ID_Spec":32,"Name":"Name","Desc":"Desc"}]
32	2024-09-16 02:13:12.403753+03	2	8	[{"ID_Spec":33,"Name":"ПОИТ","Desc":"Desc"}]
33	2024-09-16 02:17:47.09743+03	2	8	[{"ID_Spec":34,"Name":"НОвый","Desc":"Desc"}]
34	2024-09-16 03:34:44.257793+03	2	8	[{"ID_Spec":35,"Name":"Инженерия искусственного интеллекта и машинного об","Desc":"asdd"}]
35	2024-09-16 03:57:15.993739+03	2	8	[{"ID_Spec":36,"Name":"Новый","Desc":"фыв"}]
36	2024-09-16 03:58:48.361679+03	2	8	[{"ID_Spec":37,"Name":"Yjdsq","Desc":"asd"}]
37	2024-09-16 15:43:44.111501+03	1	8	{"table": "Specialties", "changes": [{"Desc": "asd -> Desc1", "Name": "Yjdsq -> Name", "ID_Spec": 37}]}
38	2024-09-17 08:24:15.045434+03	2	8	{"table": "Specialties", "inserted": [{"Desc": "фыв", "Name": "ПОИТ2", "ID_Spec": 38}]}
39	2024-09-17 09:22:24.780831+03	1	8	{"table": "Specialties", "changes": [{"Desc": "фыв", "Name": "ПОИТ2 -> ПОИТ3", "ID_Spec": 38}]}
40	2024-09-17 09:58:18.94997+03	3	8	{"table": "Specialties", "deleted": [{"Desc": "Desc", "Name": "Name", "ID_Spec": 32}]}
41	2024-09-17 10:18:52.781824+03	2	8	{"table": "Specialties", "inserted": [{"Desc": "новый", "Name": "Добавить", "ID_Spec": 39}]}
42	2024-09-17 10:19:22.336595+03	1	8	{"table": "Specialties", "changes": [{"Desc": "новый -> новый2", "Name": "Добавить", "ID_Spec": 39}]}
43	2024-09-17 10:19:29.158337+03	3	8	{"table": "Specialties", "deleted": [{"Desc": "новый2", "Name": "Добавить", "ID_Spec": 39}]}
44	2024-09-17 10:52:41.203686+03	3	8	{"table": "Specialties", "deleted": [{"Desc": "фыв", "Name": "Новый", "ID_Spec": 36}]}
45	2024-09-17 10:57:03.013919+03	3	8	{"table": "Specialties", "deleted": [{"Desc": "Desc", "Name": "НОвый", "ID_Spec": 34}]}
46	2024-09-17 10:58:35.063612+03	3	8	{"table": "Specialties", "deleted": [{"Desc": "Desc1", "Name": "Name", "ID_Spec": 37}]}
47	2024-09-17 15:46:00.609814+03	2	8	{"table": "Universities", "inserted": [{"Name": "БГУИР", "ID_Uni": 1, "Address": "ул.Козлова", "Contact_Number": "+375 29 855 76 46"}]}
48	2024-09-17 15:46:44.410832+03	2	8	{"table": "Universities", "inserted": [{"Name": "БГУ", "ID_Uni": 2, "Address": "ул.Роксоссовского", "Contact_Number": "+375 29 855 76 48"}]}
49	2024-09-17 15:52:07.664575+03	2	8	{"table": "Dormitory", "inserted": [{"ID": 1, "Name": "Общежитие 1", "Address": "фывфыв", "Contact_Number": "фывфывв1"}]}
50	2024-09-17 15:52:35.406033+03	2	8	{"table": "Students", "inserted": [{"ID": 1, "Sex": false, "Name": "ф", "Email": "фыв", "ID_Uni": 1, "Surname": "ф", "ID_Speci": 33, "Birth_Date": "2024-09-16", "Patronymic": "ф", "ID_Dormitory": 1, "Contact_Number": "фыв"}]}
51	2024-09-18 11:57:27.219129+03	2	8	{"table": "specialties", "inserted": [{"desc": "описание", "name": "Новая специальность", "id_spec": 41}]}
52	2024-09-18 11:57:39.212558+03	1	8	{"table": "specialties", "changes": [{"desc": "описание", "name": "Новая специальность -> Новая специальность2", "id_spec": 41}]}
53	2024-09-18 11:57:48.468538+03	3	8	{"table": "specialties", "deleted": [{"desc": "описание", "name": "Новая специальность2", "id_spec": 41}]}
54	2024-09-18 14:37:32.577717+03	2	8	{"table": "jobs", "inserted": [{"id": 1, "name": "asda", "acceses": {"UserAccesses": {"Reports": false, "ViewLogs": false, "FreeQueries": false, "ConfigureBackups": false}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "visits", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "jobs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": "asdd"}]}
55	2024-09-18 15:21:10.068437+03	1	8	{"table": "jobs", "changes": [{"id": 1, "name": "asda", "acceses": "{\\"UserAccesses\\": {\\"Reports\\": false, \\"ViewLogs\\": false, \\"FreeQueries\\": false, \\"ConfigureBackups\\": false}, \\"TableAccesses\\": [{\\"TableName\\": \\"сheck_ins\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"dormitory\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"students\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"visits\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs_action_types\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"rooms\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"jobs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"specialties\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"universities\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"staffs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}]} -> {\\"UserAccesses\\": {\\"Reports\\": false, \\"ViewLogs\\": true, \\"FreeQueries\\": false, \\"ConfigureBackups\\": true}, \\"TableAccesses\\": [{\\"TableName\\": \\"сheck_ins\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"dormitory\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"students\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"visits\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs_action_types\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"rooms\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"jobs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"specialties\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"universities\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"staffs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}]}", "description": "asdd -> description"}]}
56	2024-09-18 15:32:37.829052+03	2	8	{"table": "specialties", "inserted": [{"desc": "Специалисты по кибербезопасности занимаются защитой данных и систем от кибератак и угроз. Они разрабатывают и внедряют меры безопасности, проводят аудит и тестирование систем на уязвимости.", "name": "Кибербезопасность", "id_spec": 42}]}
57	2024-09-18 15:33:32.25725+03	2	8	{"table": "specialties", "inserted": [{"desc": "Специалисты в этой области разрабатывают алгоритмы и модели, которые позволяют компьютерам обучаться и принимать решения. Применение включает распознавание образов, обработку естественного языка и автономные системы.", "name": "Искусственный интеллект и машинное обучение", "id_spec": 43}]}
58	2024-09-18 15:34:05.453389+03	2	8	{"table": "specialties", "inserted": [{"desc": "Разработчики программного обеспечения создают и поддерживают приложения для различных платформ. Они работают над проектированием, кодированием, тестированием и отладкой программ.", "name": "Разработка программного обеспечения", "id_spec": 44}]}
59	2024-09-18 15:34:31.428053+03	2	8	{"table": "specialties", "inserted": [{"desc": "Аналитики данных собирают, обрабатывают и анализируют большие объемы данных для получения полезной информации. Они используют статистические методы и инструменты для визуализации данных.", "name": "Анализ данных и большие данные", "id_spec": 45}]}
60	2024-09-18 15:35:18.944672+03	2	8	{"table": "specialties", "inserted": [{"desc": "Специалисты по информационным системам управляют IT-инфраструктурой и технологиями в организациях. Они занимаются проектированием, внедрением и поддержкой информационных систем.", "name": "Информационные системы и управление", "id_spec": 46}]}
61	2024-09-18 15:35:44.69254+03	2	8	{"table": "specialties", "inserted": [{"desc": "Специалисты по сетевым технологиям занимаются проектированием, настройкой и управлением сетями. Они обеспечивают бесперебойную работу сетевой инфраструктуры и безопасность данных.", "name": "Сетевые технологии и телекоммуникации", "id_spec": 47}]}
62	2024-09-18 15:36:08.95241+03	2	8	{"table": "specialties", "inserted": [{"desc": "Разработчики игр создают видеоигры и интерактивные приложения. Они работают над графикой, анимацией, дизайном уровней и программированием игровых механик.", "name": "Разработка игр и интерактивных приложений", "id_spec": 48}]}
63	2024-09-18 15:36:35.970373+03	2	8	{"table": "specialties", "inserted": [{"desc": "Специалисты по IoT разрабатывают и управляют устройствами, подключенными к интернету. Они работают над интеграцией сенсоров, сетевых протоколов и анализом данных.", "name": "Интернет вещей (IoT)", "id_spec": 49}]}
64	2024-09-18 15:41:50.184179+03	3	8	{"table": "students", "deleted": [{"id": 1, "sex": false, "name": "ф", "email": "фыв", "id_uni": 1, "surname": "ф", "id_speci": 33, "birth_date": "2024-09-16", "patronymic": "ф", "id_dormitory": 1, "contact_number": "фыв"}]}
65	2024-09-18 15:42:00.570556+03	3	8	{"table": "specialties", "deleted": [{"desc": "Desc", "name": "ПОИТ", "id_spec": 33}]}
66	2024-09-18 15:42:05.707415+03	3	8	{"table": "specialties", "deleted": [{"desc": "asdd", "name": "Инженерия искусственного интеллекта и машинного об", "id_spec": 35}]}
67	2024-09-18 15:42:09.54329+03	3	8	{"table": "specialties", "deleted": [{"desc": "фыв", "name": "ПОИТ3", "id_spec": 38}]}
68	2024-09-22 20:16:17.210553+03	2	8	{"table": "jobs", "inserted": [{"id": 2, "name": "Вахтер", "acceses": {"UserAccesses": {"Reports": false, "ViewLogs": false, "ConfigureBackups": false}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "visits", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "jobs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": ""}]}
69	2024-09-22 20:17:21.083399+03	1	8	{"table": "dormitory", "changes": [{"id": 1, "name": "Общежитие 1", "address": "фывфыв -> УлюРоккоссвоского", "contact_number": "фывфывв1 -> "}]}
70	2024-09-22 20:20:26.195606+03	2	8	{"table": "staffs", "inserted": [{"id": 10, "name": "Иван", "login": "Ivan", "id_job": 2, "surname": "Иванов", "password": "b59c67bf196a4758191e42f76670ceba", "patronymic": "Иванич", "id_dormitory": 1, "contact_number": ""}]}
71	2024-09-22 22:27:12.305264+03	2	8	{"table": "specialties", "inserted": [{"desc": "Описание", "name": "ТестоваяСпециальность", "id_spec": 50}]}
72	2024-09-22 22:29:01.936994+03	1	8	{"table": "specialties", "changes": [{"desc": "Описание", "name": "ТестоваяСпециальность -> ТестоваяСпециальность2", "id_spec": 50}]}
73	2024-09-24 17:49:26.658654+03	2	8	{"table": "jobs", "inserted": [{"id": 3, "name": "Менеджер по персоналу", "acceses": {"UserAccesses": {"Reports": false, "ViewLogs": false, "ConfigureBackups": false}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "visits", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "jobs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": ""}]}
74	2024-09-24 17:52:13.992423+03	2	8	{"table": "jobs", "inserted": [{"id": 4, "name": "Комендант общежития", "acceses": {"UserAccesses": {"Reports": false, "ViewLogs": false, "ConfigureBackups": false}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "visits", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "jobs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": ""}]}
75	2024-09-24 17:54:02.301063+03	2	8	{"table": "jobs", "inserted": [{"id": 5, "name": "Администратор общежития", "acceses": {"UserAccesses": {"Reports": true, "ViewLogs": true, "ConfigureBackups": true}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "visits", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "jobs", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": true, "Delete": true}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": ""}]}
76	2024-09-24 17:56:32.281467+03	3	8	{"table": "jobs", "deleted": [{"id": 1, "name": "asda", "acceses": {"UserAccesses": {"Reports": false, "ViewLogs": true, "FreeQueries": false, "ConfigureBackups": true}, "TableAccesses": [{"TableName": "сheck_ins", "ViewTable": true, "TableActionsAccesses": {"Add": true, "Edit": false, "Delete": false}}, {"TableName": "dormitory", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "students", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "visits", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs_action_types", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "rooms", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "jobs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "specialties", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "universities", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "staffs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}, {"TableName": "logs", "ViewTable": false, "TableActionsAccesses": {"Add": false, "Edit": false, "Delete": false}}]}, "description": "description"}]}
77	2024-09-24 17:57:42.687791+03	1	8	{"table": "jobs", "changes": [{"id": 4, "name": "Комендант общежития", "acceses": "{\\"UserAccesses\\": {\\"Reports\\": false, \\"ViewLogs\\": false, \\"ConfigureBackups\\": false}, \\"TableAccesses\\": [{\\"TableName\\": \\"сheck_ins\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": true, \\"Delete\\": true}}, {\\"TableName\\": \\"dormitory\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"students\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": true, \\"Delete\\": true}}, {\\"TableName\\": \\"visits\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs_action_types\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"rooms\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"jobs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"specialties\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"universities\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"staffs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}]} -> {\\"UserAccesses\\": {\\"Reports\\": false, \\"ViewLogs\\": false, \\"ConfigureBackups\\": false}, \\"TableAccesses\\": [{\\"TableName\\": \\"сheck_ins\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": true, \\"Delete\\": true}}, {\\"TableName\\": \\"dormitory\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"students\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": true, \\"Delete\\": true}}, {\\"TableName\\": \\"visits\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs_action_types\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"rooms\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"jobs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"specialties\\", \\"ViewTable\\": true, \\"TableActionsAccesses\\": {\\"Add\\": true, \\"Edit\\": true, \\"Delete\\": false}}, {\\"TableName\\": \\"universities\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"staffs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}, {\\"TableName\\": \\"logs\\", \\"ViewTable\\": false, \\"TableActionsAccesses\\": {\\"Add\\": false, \\"Edit\\": false, \\"Delete\\": false}}]}", "description": " -> description"}]}
78	2024-09-24 18:09:30.301955+03	3	8	{"table": "universities", "deleted": [{"name": "БГУ", "id_uni": 2, "address": "ул.Роксоссовского", "contact_number": "+375 29 855 76 48"}]}
79	2024-09-24 18:10:44.895405+03	2	8	{"table": "staffs", "inserted": [{"id": 11, "name": "Антон", "login": "Anton", "id_job": 3, "surname": "Антонович", "password": "81dc9bdb52d04dc20036dbd8313ed055", "patronymic": "Антонов", "id_dormitory": 1, "contact_number": "+375 28 661 23 42"}]}
80	2024-09-24 18:11:59.078115+03	2	8	{"table": "staffs", "inserted": [{"id": 12, "name": "Семен", "login": "Anton", "id_job": 5, "surname": "Семнович", "password": "81dc9bdb52d04dc20036dbd8313ed055", "patronymic": "Семнов", "id_dormitory": 1, "contact_number": "+375 28 661 23 41"}]}
81	2024-09-24 18:13:35.425058+03	2	8	{"table": "staffs", "inserted": [{"id": 13, "name": "Дмитрий", "login": "Dima", "id_job": 4, "surname": "Дмитриев", "password": "81dc9bdb52d04dc20036dbd8313ed055", "patronymic": "Дмиртриевич", "id_dormitory": 1, "contact_number": "+375 28 661 23 41"}]}
82	2024-09-24 18:13:46.917031+03	3	8	{"table": "staffs", "deleted": [{"id": 12, "name": "Семен", "login": "Anton", "id_job": 5, "surname": "Семнович", "password": "81dc9bdb52d04dc20036dbd8313ed055", "patronymic": "Семнов", "id_dormitory": 1, "contact_number": "+375 28 661 23 41"}]}
83	2024-09-24 18:14:22.449106+03	2	8	{"table": "staffs", "inserted": [{"id": 14, "name": "Семен", "login": "Simen", "id_job": 5, "surname": "Семнович", "password": "81dc9bdb52d04dc20036dbd8313ed055", "patronymic": "Семнов", "id_dormitory": 1, "contact_number": "+375 28 661 23 45"}]}
\.


                                                                              4990.dat                                                                                            0000600 0004000 0002000 00000000525 14674555553 0014304 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Изменения в таблице	Информация о изменениях в таблице
2	Добавление в таблице	Информация о добавленой записе в таблице
3	Удаление из таблицы	Инфомрация об удаленных данных из таблицы
\.


                                                                                                                                                                           4994.dat                                                                                            0000600 0004000 0002000 00000000005 14674555553 0014301 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4996.dat                                                                                            0000600 0004000 0002000 00000006330 14674555553 0014312 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        42	Кибербезопасность	Специалисты по кибербезопасности занимаются защитой данных и систем от кибератак и угроз. Они разрабатывают и внедряют меры безопасности, проводят аудит и тестирование систем на уязвимости.
43	Искусственный интеллект и машинное обучение	Специалисты в этой области разрабатывают алгоритмы и модели, которые позволяют компьютерам обучаться и принимать решения. Применение включает распознавание образов, обработку естественного языка и автономные системы.
44	Разработка программного обеспечения	Разработчики программного обеспечения создают и поддерживают приложения для различных платформ. Они работают над проектированием, кодированием, тестированием и отладкой программ.
45	Анализ данных и большие данные	Аналитики данных собирают, обрабатывают и анализируют большие объемы данных для получения полезной информации. Они используют статистические методы и инструменты для визуализации данных.
46	Информационные системы и управление	Специалисты по информационным системам управляют IT-инфраструктурой и технологиями в организациях. Они занимаются проектированием, внедрением и поддержкой информационных систем.
47	Сетевые технологии и телекоммуникации	Специалисты по сетевым технологиям занимаются проектированием, настройкой и управлением сетями. Они обеспечивают бесперебойную работу сетевой инфраструктуры и безопасность данных.
48	Разработка игр и интерактивных приложений	Разработчики игр создают видеоигры и интерактивные приложения. Они работают над графикой, анимацией, дизайном уровней и программированием игровых механик.
49	Интернет вещей (IoT)	Специалисты по IoT разрабатывают и управляют устройствами, подключенными к интернету. Они работают над интеграцией сенсоров, сетевых протоколов и анализом данных.
50	ТестоваяСпециальность2	Описание
\.


                                                                                                                                                                                                                                                                                                        4998.dat                                                                                            0000600 0004000 0002000 00000000735 14674555553 0014317 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        8	\N	\N	\N	\N	\N	\N	Admin	b59c67bf196a4758191e42f76670ceba
10	Иванов	Иван	Иванич	2		1	Ivan	b59c67bf196a4758191e42f76670ceba
11	Антонович	Антон	Антонов	3	+375 28 661 23 42	1	Anton	81dc9bdb52d04dc20036dbd8313ed055
13	Дмитриев	Дмитрий	Дмиртриевич	4	+375 28 661 23 41	1	Dima	81dc9bdb52d04dc20036dbd8313ed055
14	Семнович	Семен	Семнов	5	+375 28 661 23 45	1	Simen	81dc9bdb52d04dc20036dbd8313ed055
\.


                                   5000.dat                                                                                            0000600 0004000 0002000 00000000005 14674555553 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5002.dat                                                                                            0000600 0004000 0002000 00000000070 14674555553 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	БГУИР	ул.Козлова	+375 29 855 76 46
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                        5004.dat                                                                                            0000600 0004000 0002000 00000000005 14674555553 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4984.dat                                                                                            0000600 0004000 0002000 00000000005 14674555553 0014300 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000121200 14674555553 0015403 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "Dormitory";
--
-- Name: Dormitory; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';


ALTER DATABASE "Dormitory" OWNER TO postgres;

\connect "Dormitory"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pldbgapi; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;


--
-- Name: EXTENSION pldbgapi; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';


--
-- Name: check_room_capacity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_room_capacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_occupancy INTEGER;
    max_capacity INTEGER;
BEGIN
    -- Get the current number of students in the room
    SELECT COUNT(*) INTO current_occupancy
    FROM public."сheck_ins"
    WHERE id_room = NEW.id_room AND check_out_timestamp IS NULL;

    -- Get the maximum capacity of the room
    SELECT number_of_seats INTO max_capacity
    FROM public.rooms
    WHERE id = NEW.id_room;

    -- Check if adding the new student would exceed the room's capacity
    IF current_occupancy >= max_capacity THEN
        RAISE EXCEPTION 'Room capacity exceeded. Cannot check in more students.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_room_capacity() OWNER TO postgres;

--
-- Name: check_user_credentials(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name character varying, patronymic character varying, id bigint, dormitoryname character varying, rolename character varying, acceses json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.surname, s.name, s.patronymic, s.id,d.name as dormitoryname,j.name as rolename,j.acceses 
    FROM staffs s
	Join jobs j
	on s.id_job = j.id
	Join dormitory d
	on s.id_dormitory = d."id" 
    WHERE login = p_username AND "password" = MD5(p_password);
END;
$$;


ALTER FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) OWNER TO postgres;

--
-- Name: compare_jsons(json, json, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    obj1 jsonb;
    obj2 jsonb;
	obj2_value text;
	
	json_key text;
	json_value text;
	
	temporary_json jsonb;
	json_array jsonb:='[]'::jsonb;
	
    key_value text;

BEGIN
    
	FOR obj1 IN SELECT * FROM jsonb_array_elements(json1::jsonb) LOOP
        key_value := obj1->>key_column;
        obj2 := (SELECT value FROM jsonb_array_elements(json2::jsonb) value WHERE value->>key_column = key_value::text);
        
        IF obj2 IS NOT NULL THEN
		temporary_json := '{}'::jsonb;
            FOR json_key, json_value IN SELECT key, value FROM jsonb_each(obj1) LOOP
				IF obj1->>json_key <> obj2->>json_key THEN
					obj2_value := obj2->>json_key;
                    temporary_json:= jsonb_insert(temporary_json,string_to_array(json_key,','), to_jsonb(obj1->>json_key || ' -> ' || obj2_value));
                ELSE
					temporary_json:= jsonb_insert(temporary_json,string_to_array(json_key,','),json_value::jsonb);
				END IF;
				
            END LOOP;
			json_array:= jsonb_insert(json_array, '{99999}',temporary_json);
        END IF;
    END LOOP;
    
    RETURN jsonb_build_object('table', table_name, 'changes', json_array)::json;
END;
$$;


ALTER FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) OWNER TO postgres;

--
-- Name: delete_from_table(text, text, text, bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    delete_query TEXT;
	deletedRecord RECORD;
	deleteJson json;
BEGIN
    delete_query := 'DELETE FROM public.' || quote_ident(delete_table_name) || ' WHERE ' || quote_ident(id_column) || ' = ' || id_value || ' RETURNING *';
    EXECUTE delete_query into deletedRecord;
	deleteJson:= json_agg(row_to_json(deletedRecord))::json;
	CALL insert_into_logs(3,ID_Staff,jsonb_build_object('table', delete_table_name, 'deleted', deleteJson)::json);
END;
$$;


ALTER PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint) OWNER TO postgres;

--
-- Name: delete_from_tablesf(text, text, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL delete_from_table(delete_table_name, id_column, id_value, id_staff);
END;
$$;


ALTER FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint) OWNER TO postgres;

--
-- Name: get_all_tables(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_tables() RETURNS TABLE(table_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.table_name::text 
	FROM information_schema.tables t
	WHERE t.table_schema = 'public'
	AND t.table_type = 'BASE TABLE';
END;
$$;


ALTER FUNCTION public.get_all_tables() OWNER TO postgres;

--
-- Name: get_all_views(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT table_name::text 
    FROM information_schema.views
    WHERE table_schema NOT IN ('information_schema', 'pg_catalog');
END;
$$;


ALTER FUNCTION public.get_all_views() OWNER TO postgres;

--
-- Name: get_column_info(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg_type.typname::TEXT AS column_type,
        CASE
            WHEN pg_type.typname = 'varchar' THEN pg_attribute.atttypmod - 4
            ELSE NULL
        END AS character_maximum_length,
        NOT pg_attribute.attnotnull AS is_nullable
    FROM 
        pg_attribute
    JOIN 
        pg_class ON pg_class.oid = pg_attribute.attrelid
    JOIN 
        pg_type ON pg_type.oid = pg_attribute.atttypid
    WHERE 
        pg_class.relname = table_name AND pg_attribute.attname = column_name;
END;
$$;


ALTER FUNCTION public.get_column_info(table_name text, column_name text) OWNER TO postgres;

--
-- Name: get_foreign_keys(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        tc.constraint_name::text,
        kcu.column_name::text,
        ccu.table_name::text AS referenced_table,
        ccu.column_name::text AS referenced_column
    FROM
        information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
    WHERE
        tc.constraint_type = 'FOREIGN KEY' AND
        tc.table_name = p_table_name;
END;
$$;


ALTER FUNCTION public.get_foreign_keys(p_table_name text) OWNER TO postgres;

--
-- Name: get_primary_key_column(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    pk_column text;
BEGIN
    EXECUTE format('SELECT kcu.column_name::text
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                    WHERE tc.constraint_type = ''PRIMARY KEY''
                    AND tc.table_name = %L', table_name)
    INTO pk_column;
    
    RETURN pk_column;
END;
$$;


ALTER FUNCTION public.get_primary_key_column(table_name text) OWNER TO postgres;

--
-- Name: get_table_columns(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT c."column_name"::text
    FROM information_schema.columns c
    WHERE c."table_name" = p_table_name;
END;
$$;


ALTER FUNCTION public.get_table_columns(p_table_name text) OWNER TO postgres;

--
-- Name: getcolumnindex(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcolumnindex(tablename text, tablecolumn text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
Declare
columnindex int;
BEGIN
    SELECT ordinal_position
	into columnindex
FROM information_schema.columns
WHERE table_name = tablename AND column_name = tablecolumn;
return columnindex;
END;
$$;


ALTER FUNCTION public.getcolumnindex(tablename text, tablecolumn text) OWNER TO postgres;

--
-- Name: hash_password(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.password := MD5(NEW.password);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.hash_password() OWNER TO postgres;

--
-- Name: hash_password_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.hash_password_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.password IS DISTINCT FROM OLD.password THEN
        NEW.password := MD5(NEW.password);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.hash_password_update() OWNER TO postgres;

--
-- Name: insert_into_logs(bigint, bigint, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO logs (action_timestamp, id_action_type, id_staff, action_description) 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;


ALTER PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json) OWNER TO postgres;

--
-- Name: insert_into_table(bigint, text, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    "column_name" Text;
	"column_value" text;
	column_names TEXT;
    column_values TEXT;
    insert_query TEXT;
	inserted_row RECORD;
	logJson json;
BEGIN
   column_names := '';
column_values := '';

FOR column_name, column_value IN
    SELECT key, value
    FROM json_each_text(insert_columns)
LOOP
    column_names := column_names || quote_ident(column_name) || ', ';
    column_values := column_values || quote_literal(column_value) || ', ';
END LOOP;

-- Удаляем последнюю запятую и пробел
column_names := left(column_names, length(column_names) - 2);
column_values := left(column_values, length(column_values) - 2);

insert_query := 'INSERT INTO public.' || quote_ident(insert_table_name) || ' (' || column_names || ') VALUES (' || column_values || ') RETURNING *';

	EXECUTE insert_query into inserted_row;
	SELECT json_agg(t.json_data)
INTO logJson
        FROM (
            SELECT row_to_json(inserted_row)::json AS json_data
        ) t;
	 CALL insert_into_logs(2, staff_id, jsonb_build_object('table', insert_table_name, 'inserted', logJson)::json);        
END;
$$;


ALTER PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json) OWNER TO postgres;

--
-- Name: insert_into_tablesf(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_tablesf(id text, table_name text, string text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, string::json);
END;
$$;


ALTER FUNCTION public.insert_into_tablesf(id text, table_name text, string text) OWNER TO postgres;

--
-- Name: update_table(text, text, text, json, bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    update_column_name TEXT;
    column_value TEXT;
    update_query TEXT;
	select_query text;
	
	updatedRecord RECORD;
	updatedJson json;
	selectedRecord RECORD;
	selectedJson json;
	
	finaljson json;
	
BEGIN
    update_query := 'UPDATE public."' || update_table_name || '" SET ';
    
    FOR update_column_name, column_value IN
        SELECT "key", "value"
        FROM json_each_text(update_columns)
    LOOP
        update_query := update_query || quote_ident(update_column_name) || ' = ' || quote_literal(column_value) || ', ';
    END LOOP;
    
    -- Удаляем последнюю запятую и пробел
    update_query := left(update_query, length(update_query) - 2);
    
	select_query := 'Select * from '||' public."'||update_table_name||'" WHERE "' || id_column || '" = ' || id_value;
    update_query := update_query || ' WHERE "' || id_column || '" = ' || id_value || ' RETURNING *';
	
	
	EXECUTE select_query into selectedRecord;
    EXECUTE update_query into updatedRecord;
	
	updatedJson:= json_agg(row_to_json(updatedRecord))::json;
	selectedJson:= json_agg(row_to_json(selectedRecord))::json;
	
	Select compare_jsons(selectedJson,updatedJson,update_table_name,id_column) into finaljson;
	
	CALL insert_into_logs(1,ID_Staff, finaljson);
END;
$$;


ALTER PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint) OWNER TO postgres;

--
-- Name: update_tablesf(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL update_table(update_table_name,id_column,id_value ,update_columns::json,id_staff::bigint);
END;
$$;


ALTER FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: сheck_ins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."сheck_ins" (
    id bigint NOT NULL,
    id_stud bigint,
    id_room bigint,
    check_in_timestamp timestamp with time zone
);


ALTER TABLE public."сheck_ins" OWNER TO postgres;

--
-- Name: Check_In_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Check_In_ID_seq" OWNER TO postgres;

--
-- Name: Check_In_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."сheck_ins".id;


--
-- Name: dormitory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dormitory (
    id bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);


ALTER TABLE public.dormitory OWNER TO postgres;

--
-- Name: Dormitory_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Dormitory_ID_seq" OWNER TO postgres;

--
-- Name: Dormitory_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public.dormitory.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    name character varying(50),
    acceses json,
    description text
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: Job_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Job_ID_seq" OWNER TO postgres;

--
-- Name: Job_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Job_ID_seq" OWNED BY public.jobs.id;


--
-- Name: logs_action_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs_action_types (
    id bigint NOT NULL,
    name character varying(50),
    description text
);


ALTER TABLE public.logs_action_types OWNER TO postgres;

--
-- Name: Logs_Action_Types_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNER TO postgres;

--
-- Name: Logs_Action_Types_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public.logs_action_types.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id bigint NOT NULL,
    action_timestamp timestamp with time zone,
    id_action_type bigint,
    id_staff bigint,
    action_description json
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: Logs_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Logs_ID_seq" OWNER TO postgres;

--
-- Name: Logs_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public.logs.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id bigint NOT NULL,
    room_number bigint,
    floor integer,
    number_of_seats integer,
    id_dormitory bigint
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: Rooms_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Rooms_ID_seq" OWNER TO postgres;

--
-- Name: Rooms_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public.rooms.id;


--
-- Name: specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialties (
    id_spec bigint NOT NULL,
    name character varying(50),
    "desc" text
);


ALTER TABLE public.specialties OWNER TO postgres;

--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNER TO postgres;

--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public.specialties.id_spec;


--
-- Name: staffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staffs (
    id bigint NOT NULL,
    surname character varying(50),
    name character varying(50),
    patronymic character varying(50),
    id_job bigint,
    contact_number character varying(20),
    id_dormitory bigint,
    login character varying(50),
    password character varying(255)
);


ALTER TABLE public.staffs OWNER TO postgres;

--
-- Name: Staff_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Staff_ID_seq" OWNER TO postgres;

--
-- Name: Staff_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public.staffs.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id bigint NOT NULL,
    surname character varying(50),
    name character varying(50),
    patronymic character varying(50),
    birth_date date,
    sex boolean,
    contact_number character varying(20),
    email character varying(50),
    id_uni bigint,
    id_speci bigint,
    id_dormitory bigint
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: Students_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Students_ID_seq" OWNER TO postgres;

--
-- Name: Students_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Students_ID_seq" OWNED BY public.students.id;


--
-- Name: universities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.universities (
    id_uni bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);


ALTER TABLE public.universities OWNER TO postgres;

--
-- Name: Universities_ID_Uni_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNER TO postgres;

--
-- Name: Universities_ID_Uni_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public.universities.id_uni;


--
-- Name: visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visits (
    id bigint NOT NULL,
    id_stud bigint,
    date_time_entered timestamp with time zone,
    date_time_leaved timestamp with time zone
);


ALTER TABLE public.visits OWNER TO postgres;

--
-- Name: Visits_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Visits_ID_seq" OWNER TO postgres;

--
-- Name: Visits_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public.visits.id;


--
-- Name: check_ins_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.check_ins_details AS
 SELECT ci.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    r.room_number AS "Room_Number",
    ci.check_in_timestamp AS "Check_In_Timestamp",
    d.name AS "Dormitory_Name"
   FROM (((public."сheck_ins" ci
     JOIN public.rooms r ON ((ci.id_room = r.id)))
     JOIN public.students s ON ((ci.id_stud = s.id)))
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));


ALTER VIEW public.check_ins_details OWNER TO postgres;

--
-- Name: logs_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.logs_details AS
 SELECT l.id AS "ID",
    l.action_timestamp AS "Action_Timestamp",
    lat.name AS "Action_Type",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic"
   FROM ((public.logs l
     JOIN public.logs_action_types lat ON ((l.id_action_type = lat.id)))
     JOIN public.staffs s ON ((s.id = l.id_staff)));


ALTER VIEW public.logs_details OWNER TO postgres;

--
-- Name: rooms_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rooms_details AS
 SELECT r.id AS "ID",
    r.room_number AS "Room_Number",
    r.floor AS "Floor",
    r.number_of_seats AS "Number_Of_Seats",
    d.name AS "Dormitory_Name"
   FROM (public.rooms r
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));


ALTER VIEW public.rooms_details OWNER TO postgres;

--
-- Name: staffs_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.staffs_details AS
 SELECT s.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    j.name AS "Job_Name",
    s.contact_number AS "Contact_Number",
    d.name AS "Dormitory_Name"
   FROM ((public.staffs s
     JOIN public.jobs j ON ((s.id_job = j.id)))
     JOIN public.dormitory d ON ((d.id = s.id_dormitory)));


ALTER VIEW public.staffs_details OWNER TO postgres;

--
-- Name: student_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.student_details AS
 SELECT s.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    s.birth_date AS "Birth_Date",
    s.sex AS "Sex",
    s.contact_number AS "Contact_Number",
    s.email AS "Email",
    u.name AS "University_Name",
    d.name AS "Dormitory_Name",
    sp.name AS "Specialties_Name"
   FROM (((public.students s
     JOIN public.universities u ON ((s.id_uni = u.id_uni)))
     JOIN public.dormitory d ON ((s.id_dormitory = d.id)))
     JOIN public.specialties sp ON ((s.id_speci = sp.id_spec)));


ALTER VIEW public.student_details OWNER TO postgres;

--
-- Name: visits_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.visits_details AS
 SELECT v.id AS "ID",
    v.date_time_entered AS "Date_Time_Entered",
    v.date_time_leaved AS "Date_Time_Leaved",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic"
   FROM (public.visits v
     JOIN public.students s ON ((v.id_stud = s.id)));


ALTER VIEW public.visits_details OWNER TO postgres;

--
-- Name: dormitory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dormitory ALTER COLUMN id SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public."Job_ID_seq"'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);


--
-- Name: logs_action_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs_action_types ALTER COLUMN id SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);


--
-- Name: specialties id_spec; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties ALTER COLUMN id_spec SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);


--
-- Name: staffs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs ALTER COLUMN id SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public."Students_ID_seq"'::regclass);


--
-- Name: universities id_uni; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.universities ALTER COLUMN id_uni SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);


--
-- Name: сheck_ins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."сheck_ins" ALTER COLUMN id SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);


--
-- Data for Name: dormitory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dormitory (id, name, address, contact_number) FROM stdin;
\.
COPY public.dormitory (id, name, address, contact_number) FROM '$$PATH$$/4986.dat';

--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, name, acceses, description) FROM stdin;
\.
COPY public.jobs (id, name, acceses, description) FROM '$$PATH$$/4988.dat';

--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM stdin;
\.
COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM '$$PATH$$/4992.dat';

--
-- Data for Name: logs_action_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs_action_types (id, name, description) FROM stdin;
\.
COPY public.logs_action_types (id, name, description) FROM '$$PATH$$/4990.dat';

--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM stdin;
\.
COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM '$$PATH$$/4994.dat';

--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id_spec, name, "desc") FROM stdin;
\.
COPY public.specialties (id_spec, name, "desc") FROM '$$PATH$$/4996.dat';

--
-- Data for Name: staffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM stdin;
\.
COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM '$$PATH$$/4998.dat';

--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM stdin;
\.
COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM '$$PATH$$/5000.dat';

--
-- Data for Name: universities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.universities (id_uni, name, address, contact_number) FROM stdin;
\.
COPY public.universities (id_uni, name, address, contact_number) FROM '$$PATH$$/5002.dat';

--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM stdin;
\.
COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM '$$PATH$$/5004.dat';

--
-- Data for Name: сheck_ins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp) FROM stdin;
\.
COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp) FROM '$$PATH$$/4984.dat';

--
-- Name: Check_In_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);


--
-- Name: Dormitory_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, true);


--
-- Name: Job_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Job_ID_seq"', 5, true);


--
-- Name: Logs_Action_Types_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);


--
-- Name: Logs_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_ID_seq"', 83, true);


--
-- Name: Rooms_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);


--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 50, true);


--
-- Name: Staff_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Staff_ID_seq"', 14, true);


--
-- Name: Students_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Students_ID_seq"', 1, true);


--
-- Name: Universities_ID_Uni_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 2, true);


--
-- Name: Visits_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);


--
-- Name: сheck_ins Check_Ins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY (id);


--
-- Name: dormitory Dormitory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dormitory
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY (id);


--
-- Name: jobs Job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY (id);


--
-- Name: logs_action_types Logs_Action_Types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs_action_types
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY (id);


--
-- Name: logs Logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY (id);


--
-- Name: rooms Rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY (id);


--
-- Name: specialties Specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY (id_spec);


--
-- Name: staffs Staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY (id);


--
-- Name: students Students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY (id);


--
-- Name: universities Universities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.universities
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY (id_uni);


--
-- Name: visits Visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY (id);


--
-- Name: rooms uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT uniq UNIQUE (room_number);


--
-- Name: staffs uniqLogin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "uniqLogin" UNIQUE (login);


--
-- Name: specialties uniqName; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT "uniqName" UNIQUE (name);


--
-- Name: сheck_ins uniqstud; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT uniqstud UNIQUE (id_stud);


--
-- Name: index_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_id ON public.dormitory USING btree (id);


--
-- Name: index_idcheck_ins; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idcheck_ins ON public."сheck_ins" USING btree (id);


--
-- Name: index_idjobs; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idjobs ON public.jobs USING btree (id);


--
-- Name: index_idlogs; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idlogs ON public.logs USING btree (id);


--
-- Name: index_idlogs_a_t; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idlogs_a_t ON public.logs_action_types USING btree (id);


--
-- Name: index_idrooms; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idrooms ON public.rooms USING btree (id);


--
-- Name: index_idspecialties; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idspecialties ON public.specialties USING btree (id_spec);


--
-- Name: index_idstaff; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idstaff ON public.staffs USING btree (id);


--
-- Name: index_idstudents; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idstudents ON public.students USING btree (id);


--
-- Name: index_iduniversities; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_iduniversities ON public.universities USING btree (id_uni);


--
-- Name: index_idvisits; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_idvisits ON public.visits USING btree (id);


--
-- Name: staffs before_insert_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password();


--
-- Name: staffs before_update_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();


--
-- Name: сheck_ins check_room_capacity_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_room_capacity_trigger BEFORE INSERT OR UPDATE ON public."сheck_ins" FOR EACH ROW EXECUTE FUNCTION public.check_room_capacity();


--
-- Name: logs FK_Action; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Action" FOREIGN KEY (id_action_type) REFERENCES public.logs_action_types(id) NOT VALID;


--
-- Name: students FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;


--
-- Name: staffs FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;


--
-- Name: rooms FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;


--
-- Name: staffs FK_Jobs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY (id_job) REFERENCES public.jobs(id) NOT VALID;


--
-- Name: сheck_ins FK_Room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY (id_room) REFERENCES public.rooms(id) NOT VALID;


--
-- Name: students FK_Specialites; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY (id_speci) REFERENCES public.specialties(id_spec) NOT VALID;


--
-- Name: logs FK_Staff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY (id_staff) REFERENCES public.staffs(id) NOT VALID;


--
-- Name: visits FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;


--
-- Name: сheck_ins FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;


--
-- Name: students FK_University; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_University" FOREIGN KEY (id_uni) REFERENCES public.universities(id_uni) NOT VALID;


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
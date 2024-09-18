toc.dat                                                                                             0000600 0004000 0002000 00000130575 14672513740 0014463 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   #                    |         	   Dormitory    16.4    16.4 x    {           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         |           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         }           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         ~           1262    34580 	   Dormitory    DATABASE     �   CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';
    DROP DATABASE "Dormitory";
                postgres    false                     3079    34581    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false                    0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    2         !           1255    34618 <   check_user_credentials(character varying, character varying)    FUNCTION     u  CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name text, patronymic character varying, id bigint, dormitoryname bigint, rolename character varying, acceses json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s."Surname", s."Name", s."Patronymic", s."ID",d."Name" as "Dormitory_Name",j."Name",j."Acceses" 
    FROM public."Staffs" s
	Join public."Jobs" j
	on s."ID_Jobs" = j."ID"
	Join public."Dormitory" d
	on s."ID_Dormitory" = "ID" 
    WHERE "Login" = p_username AND "Password" = MD5(p_password);
END;
$$;
 i   DROP FUNCTION public.check_user_credentials(p_username character varying, p_password character varying);
       public          postgres    false         "           1255    34619 %   compare_jsons(json, json, text, text)    FUNCTION       CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
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
       public          postgres    false         #           1255    34620 +   delete_from_table(text, text, text, bigint) 	   PROCEDURE     f  CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint)
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
       public          postgres    false         $           1255    34621 -   delete_from_tablesf(text, text, text, bigint)    FUNCTION     �   CREATE FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL delete_from_table(delete_table_name, id_column, id_value, id_staff);
END;
$$;
 r   DROP FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint);
       public          postgres    false         %           1255    34622    get_all_tables()    FUNCTION     
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
       public          postgres    false         &           1255    34623    get_all_views()    FUNCTION       CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
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
       public          postgres    false                    1255    34624    get_column_info(text, text)    FUNCTION     �  CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
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
       public          postgres    false                    1255    34625    get_foreign_keys(text)    FUNCTION       CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
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
       public          postgres    false                    1255    34626    get_primary_key_column(text)    FUNCTION     k  CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
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
       public          postgres    false                    1255    34627    get_table_columns(text)    FUNCTION       CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
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
       public          postgres    false                    1255    34628    getcolumnindex(text, text)    FUNCTION     =  CREATE FUNCTION public.getcolumnindex(tablename text, tablecolumn text) RETURNS integer
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
       public          postgres    false                    1255    34629    hash_password()    FUNCTION     �   CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."Password" := MD5(NEW."Password");
    RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false                    1255    34630    hash_password_update()    FUNCTION     �   CREATE FUNCTION public.hash_password_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."Password" IS DISTINCT FROM OLD."Password" THEN
        NEW."Password" := MD5(NEW."Password");
    END IF;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.hash_password_update();
       public          postgres    false                    1255    34631 &   insert_into_logs(bigint, bigint, json) 	   PROCEDURE     3  CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO logs (action_timestamp, id_action_type, id_staff, action_description) 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;
 p   DROP PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json);
       public          postgres    false         '           1255    34632 %   insert_into_table(bigint, text, json) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json)
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
       public          postgres    false         (           1255    34633 %   insert_into_tablesf(text, text, text)    FUNCTION     �   CREATE FUNCTION public.insert_into_tablesf(id text, table_name text, string text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, string::json);
END;
$$;
 Q   DROP FUNCTION public.insert_into_tablesf(id text, table_name text, string text);
       public          postgres    false         )           1255    34634 ,   update_table(text, text, text, json, bigint) 	   PROCEDURE     �  CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint)
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
       public          postgres    false         *           1255    34635 ,   update_tablesf(text, text, text, text, text)    FUNCTION        CREATE FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL update_table(update_table_name,id_column,id_value ,update_columns::json,id_staff::bigint);
END;
$$;
 �   DROP FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text);
       public          postgres    false         �            1259    34636 
   сheck_ins    TABLE     �   CREATE TABLE public."сheck_ins" (
    id bigint NOT NULL,
    id_stud bigint,
    id_room bigint,
    check_in_timestamp timestamp with time zone,
    check_out_timestamp timestamp with time zone
);
     DROP TABLE public."сheck_ins";
       public         heap    postgres    false         �            1259    34639    Check_In_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Check_In_ID_seq";
       public          postgres    false    221         �           0    0    Check_In_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."сheck_ins".id;
          public          postgres    false    222         �            1259    34640 	   dormitory    TABLE     �   CREATE TABLE public.dormitory (
    id bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);
    DROP TABLE public.dormitory;
       public         heap    postgres    false         �            1259    34643    Dormitory_ID_seq    SEQUENCE     {   CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public."Dormitory_ID_seq";
       public          postgres    false    223         �           0    0    Dormitory_ID_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public.dormitory.id;
          public          postgres    false    224         �            1259    34644    jobs    TABLE     }   CREATE TABLE public.jobs (
    id bigint NOT NULL,
    name character varying(50),
    acceses json,
    description text
);
    DROP TABLE public.jobs;
       public         heap    postgres    false         �            1259    34649 
   Job_ID_seq    SEQUENCE     u   CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public."Job_ID_seq";
       public          postgres    false    225         �           0    0 
   Job_ID_seq    SEQUENCE OWNED BY     <   ALTER SEQUENCE public."Job_ID_seq" OWNED BY public.jobs.id;
          public          postgres    false    226         �            1259    34655    logs_action_types    TABLE     x   CREATE TABLE public.logs_action_types (
    id bigint NOT NULL,
    name character varying(50),
    description text
);
 %   DROP TABLE public.logs_action_types;
       public         heap    postgres    false         �            1259    34660    Logs_Action_Types_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Logs_Action_Types_ID_seq";
       public          postgres    false    228         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public.logs_action_types.id;
          public          postgres    false    229         �            1259    34650    logs    TABLE     �   CREATE TABLE public.logs (
    id bigint NOT NULL,
    action_timestamp timestamp with time zone,
    id_action_type bigint,
    id_staff bigint,
    action_description json
);
    DROP TABLE public.logs;
       public         heap    postgres    false         �            1259    34661    Logs_ID_seq    SEQUENCE     v   CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."Logs_ID_seq";
       public          postgres    false    227         �           0    0    Logs_ID_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public.logs.id;
          public          postgres    false    230         �            1259    34662    rooms    TABLE     �   CREATE TABLE public.rooms (
    id bigint NOT NULL,
    room_number bigint,
    floor integer,
    number_of_seats integer,
    id_dormitory bigint
);
    DROP TABLE public.rooms;
       public         heap    postgres    false         �            1259    34665    Rooms_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Rooms_ID_seq";
       public          postgres    false    231         �           0    0    Rooms_ID_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public.rooms.id;
          public          postgres    false    232         �            1259    34666    specialties    TABLE     r   CREATE TABLE public.specialties (
    id_spec bigint NOT NULL,
    name character varying(50),
    "desc" text
);
    DROP TABLE public.specialties;
       public         heap    postgres    false         �            1259    34671    Specialties_ID_Spec_seq    SEQUENCE     �   CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Specialties_ID_Spec_seq";
       public          postgres    false    233         �           0    0    Specialties_ID_Spec_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public.specialties.id_spec;
          public          postgres    false    234         �            1259    34672    staffs    TABLE     <  CREATE TABLE public.staffs (
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
       public         heap    postgres    false         �            1259    34675    Staff_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Staff_ID_seq";
       public          postgres    false    235         �           0    0    Staff_ID_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public.staffs.id;
          public          postgres    false    236         �            1259    34676    students    TABLE     T  CREATE TABLE public.students (
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
       public         heap    postgres    false         �            1259    34679    Students_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Students_ID_seq";
       public          postgres    false    237         �           0    0    Students_ID_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."Students_ID_seq" OWNED BY public.students.id;
          public          postgres    false    238         �            1259    34680    universities    TABLE     �   CREATE TABLE public.universities (
    id_uni bigint NOT NULL,
    name character varying(50),
    address character varying(255),
    contact_number character varying(20)
);
     DROP TABLE public.universities;
       public         heap    postgres    false         �            1259    34683    Universities_ID_Uni_seq    SEQUENCE     �   CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Universities_ID_Uni_seq";
       public          postgres    false    239         �           0    0    Universities_ID_Uni_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public.universities.id_uni;
          public          postgres    false    240         �            1259    34684    visits    TABLE     �   CREATE TABLE public.visits (
    id bigint NOT NULL,
    id_stud bigint,
    date_time_entered timestamp with time zone,
    date_time_leaved timestamp with time zone
);
    DROP TABLE public.visits;
       public         heap    postgres    false         �            1259    34687    Visits_ID_seq    SEQUENCE     x   CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Visits_ID_seq";
       public          postgres    false    241         �           0    0    Visits_ID_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public.visits.id;
          public          postgres    false    242         �            1259    34688    check_ins_details    VIEW       CREATE VIEW public.check_ins_details AS
 SELECT ci.id AS "ID",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic",
    r.room_number AS "Room_Number",
    ci.check_in_timestamp AS "Check_In_Timestamp",
    ci.check_out_timestamp AS "Check_Out_Timestamp",
    d.name AS "Dormitory_Name"
   FROM (((public."сheck_ins" ci
     JOIN public.rooms r ON ((ci.id_room = r.id)))
     JOIN public.students s ON ((ci.id_stud = s.id)))
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));
 $   DROP VIEW public.check_ins_details;
       public          postgres    false    223    237    237    237    237    231    231    231    223    221    221    221    221    221         �            1259    34693    logs_details    VIEW     o  CREATE VIEW public.logs_details AS
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
       public          postgres    false    227    235    235    235    235    228    228    227    227    227         �            1259    34697    rooms_details    VIEW       CREATE VIEW public.rooms_details AS
 SELECT r.id AS "ID",
    r.room_number AS "Room_Number",
    r.floor AS "Floor",
    r.number_of_seats AS "Number_Of_Seats",
    d.name AS "Dormitory_Name"
   FROM (public.rooms r
     JOIN public.dormitory d ON ((r.id_dormitory = d.id)));
     DROP VIEW public.rooms_details;
       public          postgres    false    231    223    223    231    231    231    231         �            1259    34701    staffs_details    VIEW     x  CREATE VIEW public.staffs_details AS
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
       public          postgres    false    235    235    235    235    235    223    223    235    225    225    235         �            1259    34706    student_details    VIEW     @  CREATE VIEW public.student_details AS
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
       public          postgres    false    237    239    239    237    237    237    237    237    237    237    237    237    237    233    233    223    223         �            1259    34711    visits_details    VIEW     ;  CREATE VIEW public.visits_details AS
 SELECT v.id AS "ID",
    v.date_time_entered AS "Date_Time_Entered",
    v.date_time_leaved AS "Date_Time_Leaved",
    s.surname AS "Surname",
    s.name AS "Name",
    s.patronymic AS "Patronymic"
   FROM (public.visits v
     JOIN public.students s ON ((v.id_stud = s.id)));
 !   DROP VIEW public.visits_details;
       public          postgres    false    237    241    241    241    241    237    237    237         �           2604    34716    dormitory id    DEFAULT     n   ALTER TABLE ONLY public.dormitory ALTER COLUMN id SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);
 ;   ALTER TABLE public.dormitory ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223         �           2604    34717    jobs id    DEFAULT     c   ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public."Job_ID_seq"'::regclass);
 6   ALTER TABLE public.jobs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225         �           2604    34718    logs id    DEFAULT     d   ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);
 6   ALTER TABLE public.logs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    227         �           2604    34719    logs_action_types id    DEFAULT     ~   ALTER TABLE ONLY public.logs_action_types ALTER COLUMN id SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);
 C   ALTER TABLE public.logs_action_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228         �           2604    34720    rooms id    DEFAULT     f   ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);
 7   ALTER TABLE public.rooms ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231         �           2604    34721    specialties id_spec    DEFAULT     |   ALTER TABLE ONLY public.specialties ALTER COLUMN id_spec SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);
 B   ALTER TABLE public.specialties ALTER COLUMN id_spec DROP DEFAULT;
       public          postgres    false    234    233         �           2604    34722 	   staffs id    DEFAULT     g   ALTER TABLE ONLY public.staffs ALTER COLUMN id SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);
 8   ALTER TABLE public.staffs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    236    235         �           2604    34723    students id    DEFAULT     l   ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public."Students_ID_seq"'::regclass);
 :   ALTER TABLE public.students ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    238    237         �           2604    34724    universities id_uni    DEFAULT     |   ALTER TABLE ONLY public.universities ALTER COLUMN id_uni SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);
 B   ALTER TABLE public.universities ALTER COLUMN id_uni DROP DEFAULT;
       public          postgres    false    240    239         �           2604    34725 	   visits id    DEFAULT     h   ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);
 8   ALTER TABLE public.visits ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    242    241         �           2604    34715    сheck_ins id    DEFAULT     p   ALTER TABLE ONLY public."сheck_ins" ALTER COLUMN id SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);
 >   ALTER TABLE public."сheck_ins" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221         e          0    34640 	   dormitory 
   TABLE DATA           F   COPY public.dormitory (id, name, address, contact_number) FROM stdin;
    public          postgres    false    223       4965.dat g          0    34644    jobs 
   TABLE DATA           >   COPY public.jobs (id, name, acceses, description) FROM stdin;
    public          postgres    false    225       4967.dat i          0    34650    logs 
   TABLE DATA           b   COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM stdin;
    public          postgres    false    227       4969.dat j          0    34655    logs_action_types 
   TABLE DATA           B   COPY public.logs_action_types (id, name, description) FROM stdin;
    public          postgres    false    228       4970.dat m          0    34662    rooms 
   TABLE DATA           V   COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM stdin;
    public          postgres    false    231       4973.dat o          0    34666    specialties 
   TABLE DATA           <   COPY public.specialties (id_spec, name, "desc") FROM stdin;
    public          postgres    false    233       4975.dat q          0    34672    staffs 
   TABLE DATA           v   COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM stdin;
    public          postgres    false    235       4977.dat s          0    34676    students 
   TABLE DATA           �   COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM stdin;
    public          postgres    false    237       4979.dat u          0    34680    universities 
   TABLE DATA           M   COPY public.universities (id_uni, name, address, contact_number) FROM stdin;
    public          postgres    false    239       4981.dat w          0    34684    visits 
   TABLE DATA           R   COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM stdin;
    public          postgres    false    241       4983.dat c          0    34636 
   сheck_ins 
   TABLE DATA           e   COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp, check_out_timestamp) FROM stdin;
    public          postgres    false    221       4963.dat �           0    0    Check_In_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);
          public          postgres    false    222         �           0    0    Dormitory_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, true);
          public          postgres    false    224         �           0    0 
   Job_ID_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public."Job_ID_seq"', 1, false);
          public          postgres    false    226         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);
          public          postgres    false    229         �           0    0    Logs_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Logs_ID_seq"', 53, true);
          public          postgres    false    230         �           0    0    Rooms_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);
          public          postgres    false    232         �           0    0    Specialties_ID_Spec_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 41, true);
          public          postgres    false    234         �           0    0    Staff_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Staff_ID_seq"', 8, true);
          public          postgres    false    236         �           0    0    Students_ID_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."Students_ID_seq"', 1, true);
          public          postgres    false    238         �           0    0    Universities_ID_Uni_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 2, true);
          public          postgres    false    240         �           0    0    Visits_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);
          public          postgres    false    242         �           2606    34727    сheck_ins Check_Ins_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY (id);
 G   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "Check_Ins_pkey";
       public            postgres    false    221         �           2606    34729    dormitory Dormitory_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.dormitory
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.dormitory DROP CONSTRAINT "Dormitory_pkey";
       public            postgres    false    223         �           2606    34731    jobs Job_pkey 
   CONSTRAINT     M   ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY (id);
 9   ALTER TABLE ONLY public.jobs DROP CONSTRAINT "Job_pkey";
       public            postgres    false    225         �           2606    34733 (   logs_action_types Logs_Action_Types_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.logs_action_types
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.logs_action_types DROP CONSTRAINT "Logs_Action_Types_pkey";
       public            postgres    false    228         �           2606    34735    logs Logs_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.logs DROP CONSTRAINT "Logs_pkey";
       public            postgres    false    227         �           2606    34737    rooms Rooms_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.rooms DROP CONSTRAINT "Rooms_pkey";
       public            postgres    false    231         �           2606    34739    specialties Specialties_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY (id_spec);
 H   ALTER TABLE ONLY public.specialties DROP CONSTRAINT "Specialties_pkey";
       public            postgres    false    233         �           2606    34741    staffs Staff_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY (id);
 =   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "Staff_pkey";
       public            postgres    false    235         �           2606    34743    students Students_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.students DROP CONSTRAINT "Students_pkey";
       public            postgres    false    237         �           2606    34745    universities Universities_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.universities
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY (id_uni);
 J   ALTER TABLE ONLY public.universities DROP CONSTRAINT "Universities_pkey";
       public            postgres    false    239         �           2606    34747    visits Visits_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.visits DROP CONSTRAINT "Visits_pkey";
       public            postgres    false    241         �           2620    34748 "   staffs before_insert_hash_password    TRIGGER     �   CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 ;   DROP TRIGGER before_insert_hash_password ON public.staffs;
       public          postgres    false    235    274         �           2620    34749 "   staffs before_update_hash_password    TRIGGER     �   CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();
 ;   DROP TRIGGER before_update_hash_password ON public.staffs;
       public          postgres    false    275    235         �           2606    34750    logs FK_Action    FK CONSTRAINT     �   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Action" FOREIGN KEY (id_action_type) REFERENCES public.logs_action_types(id) NOT VALID;
 :   ALTER TABLE ONLY public.logs DROP CONSTRAINT "FK_Action";
       public          postgres    false    228    4788    227         �           2606    34755    students FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 A   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    4782    237         �           2606    34760    staffs FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 ?   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    235    4782         �           2606    34765    rooms FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY (id_dormitory) REFERENCES public.dormitory(id) NOT VALID;
 >   ALTER TABLE ONLY public.rooms DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    4782    223    231         �           2606    34770    staffs FK_Jobs    FK CONSTRAINT     w   ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY (id_job) REFERENCES public.jobs(id) NOT VALID;
 :   ALTER TABLE ONLY public.staffs DROP CONSTRAINT "FK_Jobs";
       public          postgres    false    225    4784    235         �           2606    34775    сheck_ins FK_Room    FK CONSTRAINT        ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY (id_room) REFERENCES public.rooms(id) NOT VALID;
 @   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "FK_Room";
       public          postgres    false    221    231    4790         �           2606    34780    students FK_Specialites    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY (id_speci) REFERENCES public.specialties(id_spec) NOT VALID;
 C   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_Specialites";
       public          postgres    false    4792    237    233         �           2606    34785    logs FK_Staff    FK CONSTRAINT     z   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY (id_staff) REFERENCES public.staffs(id) NOT VALID;
 9   ALTER TABLE ONLY public.logs DROP CONSTRAINT "FK_Staff";
       public          postgres    false    227    235    4794         �           2606    34790    visits FK_Student    FK CONSTRAINT        ALTER TABLE ONLY public.visits
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;
 =   ALTER TABLE ONLY public.visits DROP CONSTRAINT "FK_Student";
       public          postgres    false    4796    237    241         �           2606    34795    сheck_ins FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."сheck_ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY (id_stud) REFERENCES public.students(id) NOT VALID;
 C   ALTER TABLE ONLY public."сheck_ins" DROP CONSTRAINT "FK_Student";
       public          postgres    false    4796    221    237         �           2606    34800    students FK_University    FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT "FK_University" FOREIGN KEY (id_uni) REFERENCES public.universities(id_uni) NOT VALID;
 B   ALTER TABLE ONLY public.students DROP CONSTRAINT "FK_University";
       public          postgres    false    239    4798    237                                                                                                                                           4965.dat                                                                                            0000600 0004000 0002000 00000000071 14672513740 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Общежитие 1	фывфыв	фывфывв1
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                       4967.dat                                                                                            0000600 0004000 0002000 00000000005 14672513740 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4969.dat                                                                                            0000600 0004000 0002000 00000006443 14672513740 0014305 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        31	2024-09-16 02:12:52.835511+03	2	8	[{"ID_Spec":32,"Name":"Name","Desc":"Desc"}]
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
\.


                                                                                                                                                                                                                             4970.dat                                                                                            0000600 0004000 0002000 00000000525 14672513740 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Изменения в таблице	Информация о изменениях в таблице
2	Добавление в таблице	Информация о добавленой записе в таблице
3	Удаление из таблицы	Инфомрация об удаленных данных из таблицы
\.


                                                                                                                                                                           4973.dat                                                                                            0000600 0004000 0002000 00000000005 14672513740 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4975.dat                                                                                            0000600 0004000 0002000 00000000222 14672513740 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        33	ПОИТ	Desc
35	Инженерия искусственного интеллекта и машинного об	asdd
38	ПОИТ3	фыв
\.


                                                                                                                                                                                                                                                                                                                                                                              4977.dat                                                                                            0000600 0004000 0002000 00000000100 14672513740 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        8	\N	\N	\N	\N	\N	\N	Admin	b59c67bf196a4758191e42f76670ceba
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                4979.dat                                                                                            0000600 0004000 0002000 00000000062 14672513740 0014275 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	ф	ф	ф	2024-09-16	f	фыв	фыв	1	33	1
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                              4981.dat                                                                                            0000600 0004000 0002000 00000000165 14672513740 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	БГУИР	ул.Козлова	+375 29 855 76 46
2	БГУ	ул.Роксоссовского	+375 29 855 76 48
\.


                                                                                                                                                                                                                                                                                                                                                                                                           4983.dat                                                                                            0000600 0004000 0002000 00000000005 14672513740 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4963.dat                                                                                            0000600 0004000 0002000 00000000005 14672513740 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000112725 14672513740 0015405 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
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
-- Name: check_user_credentials(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name text, patronymic character varying, id bigint, dormitoryname bigint, rolename character varying, acceses json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s."Surname", s."Name", s."Patronymic", s."ID",d."Name" as "Dormitory_Name",j."Name",j."Acceses" 
    FROM public."Staffs" s
	Join public."Jobs" j
	on s."ID_Jobs" = j."ID"
	Join public."Dormitory" d
	on s."ID_Dormitory" = "ID" 
    WHERE "Login" = p_username AND "Password" = MD5(p_password);
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
    NEW."Password" := MD5(NEW."Password");
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
    IF NEW."Password" IS DISTINCT FROM OLD."Password" THEN
        NEW."Password" := MD5(NEW."Password");
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
    check_in_timestamp timestamp with time zone,
    check_out_timestamp timestamp with time zone
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
    ci.check_out_timestamp AS "Check_Out_Timestamp",
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
COPY public.dormitory (id, name, address, contact_number) FROM '$$PATH$$/4965.dat';

--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, name, acceses, description) FROM stdin;
\.
COPY public.jobs (id, name, acceses, description) FROM '$$PATH$$/4967.dat';

--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM stdin;
\.
COPY public.logs (id, action_timestamp, id_action_type, id_staff, action_description) FROM '$$PATH$$/4969.dat';

--
-- Data for Name: logs_action_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs_action_types (id, name, description) FROM stdin;
\.
COPY public.logs_action_types (id, name, description) FROM '$$PATH$$/4970.dat';

--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM stdin;
\.
COPY public.rooms (id, room_number, floor, number_of_seats, id_dormitory) FROM '$$PATH$$/4973.dat';

--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id_spec, name, "desc") FROM stdin;
\.
COPY public.specialties (id_spec, name, "desc") FROM '$$PATH$$/4975.dat';

--
-- Data for Name: staffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM stdin;
\.
COPY public.staffs (id, surname, name, patronymic, id_job, contact_number, id_dormitory, login, password) FROM '$$PATH$$/4977.dat';

--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM stdin;
\.
COPY public.students (id, surname, name, patronymic, birth_date, sex, contact_number, email, id_uni, id_speci, id_dormitory) FROM '$$PATH$$/4979.dat';

--
-- Data for Name: universities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.universities (id_uni, name, address, contact_number) FROM stdin;
\.
COPY public.universities (id_uni, name, address, contact_number) FROM '$$PATH$$/4981.dat';

--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM stdin;
\.
COPY public.visits (id, id_stud, date_time_entered, date_time_leaved) FROM '$$PATH$$/4983.dat';

--
-- Data for Name: сheck_ins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp, check_out_timestamp) FROM stdin;
\.
COPY public."сheck_ins" (id, id_stud, id_room, check_in_timestamp, check_out_timestamp) FROM '$$PATH$$/4963.dat';

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

SELECT pg_catalog.setval('public."Job_ID_seq"', 1, false);


--
-- Name: Logs_Action_Types_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);


--
-- Name: Logs_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_ID_seq"', 53, true);


--
-- Name: Rooms_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);


--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 41, true);


--
-- Name: Staff_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Staff_ID_seq"', 8, true);


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
-- Name: staffs before_insert_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password();


--
-- Name: staffs before_update_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public.staffs FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();


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

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
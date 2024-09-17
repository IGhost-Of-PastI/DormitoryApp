toc.dat                                                                                             0000600 0004000 0002000 00000130140 14672237122 0014444 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP                       |         	   Dormitory    16.4    16.4 w    z           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         {           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         |           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         }           1262    34352 	   Dormitory    DATABASE     �   CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';
    DROP DATABASE "Dormitory";
                postgres    false                     3079    34353    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false         ~           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    2                     1255    34390 <   check_user_credentials(character varying, character varying)    FUNCTION     u  CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name text, patronymic character varying, id bigint, dormitoryname bigint, rolename character varying, acceses json)
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
       public          postgres    false         !           1255    34391 %   compare_jsons(json, json, text, text)    FUNCTION       CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
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
       public          postgres    false         (           1255    34393 +   delete_from_table(text, text, text, bigint) 	   PROCEDURE     f  CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value text, IN id_staff bigint)
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
       public          postgres    false         $           1255    34394 -   delete_from_tablesf(text, text, text, bigint)    FUNCTION     �   CREATE FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL delete_from_table(delete_table_name, id_column, id_value, id_staff);
END;
$$;
 r   DROP FUNCTION public.delete_from_tablesf(delete_table_name text, id_column text, id_value text, id_staff bigint);
       public          postgres    false         "           1255    34395    get_all_tables()    FUNCTION     
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
       public          postgres    false         #           1255    34396    get_all_views()    FUNCTION       CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
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
       public          postgres    false                    1255    34397    get_column_info(text, text)    FUNCTION     �  CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
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
       public          postgres    false                    1255    34398    get_foreign_keys(text)    FUNCTION       CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
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
       public          postgres    false                    1255    34399    get_primary_key_column(text)    FUNCTION     k  CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
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
       public          postgres    false                    1255    34400    get_table_columns(text)    FUNCTION       CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
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
       public          postgres    false                    1255    34401    hash_password()    FUNCTION     �   CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."Password" := MD5(NEW."Password");
    RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false                    1255    34402    hash_password_update()    FUNCTION     �   CREATE FUNCTION public.hash_password_update() RETURNS trigger
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
       public          postgres    false                    1255    34403 &   insert_into_logs(bigint, bigint, json) 	   PROCEDURE     D  CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Logs" ("Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;
 p   DROP PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json);
       public          postgres    false         %           1255    34404 %   insert_into_table(bigint, text, json) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json)
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
       public          postgres    false         &           1255    34405 %   insert_into_tablesf(text, text, text)    FUNCTION     �   CREATE FUNCTION public.insert_into_tablesf(id text, table_name text, string text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, string::json);
END;
$$;
 Q   DROP FUNCTION public.insert_into_tablesf(id text, table_name text, string text);
       public          postgres    false         )           1255    34408 ,   update_table(text, text, text, json, bigint) 	   PROCEDURE     �  CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value text, IN update_columns json, IN id_staff bigint)
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
       public          postgres    false         '           1255    34409 ,   update_tablesf(text, text, text, text, text)    FUNCTION        CREATE FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL update_table(update_table_name,id_column,id_value ,update_columns::json,id_staff::bigint);
END;
$$;
 �   DROP FUNCTION public.update_tablesf(update_table_name text, id_column text, id_value text, update_columns text, id_staff text);
       public          postgres    false         �            1259    34410 	   Check_Ins    TABLE     �   CREATE TABLE public."Check_Ins" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "ID_Room" bigint,
    "Check_In_Timestamp" timestamp with time zone,
    "Check_Out_Timestamp" timestamp with time zone
);
    DROP TABLE public."Check_Ins";
       public         heap    postgres    false         �            1259    34413    Check_In_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Check_In_ID_seq";
       public          postgres    false    221                    0    0    Check_In_ID_seq    SEQUENCE OWNED BY     J   ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."Check_Ins"."ID";
          public          postgres    false    222         �            1259    34414 	   Dormitory    TABLE     �   CREATE TABLE public."Dormitory" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
    DROP TABLE public."Dormitory";
       public         heap    postgres    false         �            1259    34417    Dormitory_ID_seq    SEQUENCE     {   CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public."Dormitory_ID_seq";
       public          postgres    false    223         �           0    0    Dormitory_ID_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public."Dormitory"."ID";
          public          postgres    false    224         �            1259    34418    Jobs    TABLE     �   CREATE TABLE public."Jobs" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Acceses" json,
    "Description" text
);
    DROP TABLE public."Jobs";
       public         heap    postgres    false         �            1259    34423 
   Job_ID_seq    SEQUENCE     u   CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public."Job_ID_seq";
       public          postgres    false    225         �           0    0 
   Job_ID_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public."Job_ID_seq" OWNED BY public."Jobs"."ID";
          public          postgres    false    226         �            1259    34424    Logs    TABLE     �   CREATE TABLE public."Logs" (
    "ID" bigint NOT NULL,
    "Action_Timestamp" timestamp with time zone,
    "ID_Action_Type" bigint,
    "ID_Staff" bigint,
    "Action_Description" json
);
    DROP TABLE public."Logs";
       public         heap    postgres    false         �            1259    34429    Logs_Action_Types    TABLE     �   CREATE TABLE public."Logs_Action_Types" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);
 '   DROP TABLE public."Logs_Action_Types";
       public         heap    postgres    false         �            1259    34434    Logs_Action_Types_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Logs_Action_Types_ID_seq";
       public          postgres    false    228         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public."Logs_Action_Types"."ID";
          public          postgres    false    229         �            1259    34435    Logs_ID_seq    SEQUENCE     v   CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."Logs_ID_seq";
       public          postgres    false    227         �           0    0    Logs_ID_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public."Logs"."ID";
          public          postgres    false    230         �            1259    34436    Rooms    TABLE     �   CREATE TABLE public."Rooms" (
    "ID" bigint NOT NULL,
    "Room_Number" bigint,
    "Floor" integer,
    "Number_Of_Seats" integer,
    "ID_Dormitory" bigint
);
    DROP TABLE public."Rooms";
       public         heap    postgres    false         �            1259    34439    Rooms_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Rooms_ID_seq";
       public          postgres    false    231         �           0    0    Rooms_ID_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public."Rooms"."ID";
          public          postgres    false    232         �            1259    34440    Specialties    TABLE     x   CREATE TABLE public."Specialties" (
    "ID_Spec" bigint NOT NULL,
    "Name" character varying(50),
    "Desc" text
);
 !   DROP TABLE public."Specialties";
       public         heap    postgres    false         �            1259    34445    Specialties_ID_Spec_seq    SEQUENCE     �   CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Specialties_ID_Spec_seq";
       public          postgres    false    233         �           0    0    Specialties_ID_Spec_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public."Specialties"."ID_Spec";
          public          postgres    false    234         �            1259    34446    Staffs    TABLE     P  CREATE TABLE public."Staffs" (
    "ID" bigint NOT NULL,
    "Surname" character varying(50),
    "Name" character varying(50),
    "Patronymic" character varying(50),
    "ID_Job" bigint,
    "Contact_Number" character varying(20),
    "ID_Dormitory" bigint,
    "Login" character varying(50),
    "Password" character varying(255)
);
    DROP TABLE public."Staffs";
       public         heap    postgres    false         �            1259    34449    Staff_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Staff_ID_seq";
       public          postgres    false    235         �           0    0    Staff_ID_seq    SEQUENCE OWNED BY     D   ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public."Staffs"."ID";
          public          postgres    false    236         �            1259    34450    Students    TABLE     l  CREATE TABLE public."Students" (
    "ID" bigint NOT NULL,
    "Surname" character varying(50),
    "Name" character varying(50),
    "Patronymic" character varying(50),
    "Birth_Date" date,
    "Sex" boolean,
    "Contact_Number" character varying(20),
    "Email" character varying(50),
    "ID_Uni" bigint,
    "ID_Speci" bigint,
    "ID_Dormitory" bigint
);
    DROP TABLE public."Students";
       public         heap    postgres    false         �            1259    34453    Students_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Students_ID_seq";
       public          postgres    false    237         �           0    0    Students_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Students_ID_seq" OWNED BY public."Students"."ID";
          public          postgres    false    238         �            1259    34454    Universities    TABLE     �   CREATE TABLE public."Universities" (
    "ID_Uni" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
 "   DROP TABLE public."Universities";
       public         heap    postgres    false         �            1259    34457    Universities_ID_Uni_seq    SEQUENCE     �   CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Universities_ID_Uni_seq";
       public          postgres    false    239         �           0    0    Universities_ID_Uni_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public."Universities"."ID_Uni";
          public          postgres    false    240         �            1259    34458    Visits    TABLE     �   CREATE TABLE public."Visits" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Date_Time_Entered" timestamp with time zone,
    "Date_Time_Leaved" timestamp with time zone
);
    DROP TABLE public."Visits";
       public         heap    postgres    false         �            1259    34461    Visits_ID_seq    SEQUENCE     x   CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Visits_ID_seq";
       public          postgres    false    241         �           0    0    Visits_ID_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public."Visits"."ID";
          public          postgres    false    242         �            1259    34462    check_ins_details    VIEW     �  CREATE VIEW public.check_ins_details AS
 SELECT ci."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    r."Room_Number",
    ci."Check_In_Timestamp",
    ci."Check_Out_Timestamp",
    d."Name" AS "Dormitory_Name"
   FROM (((public."Check_Ins" ci
     JOIN public."Rooms" r ON ((ci."ID_Room" = r."ID")))
     JOIN public."Students" s ON ((ci."ID_Stud" = s."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
 $   DROP VIEW public.check_ins_details;
       public          postgres    false    237    231    231    221    223    223    221    237    221    221    221    237    237    231         �            1259    34467    logs_details    VIEW     D  CREATE VIEW public.logs_details AS
 SELECT l."ID",
    l."Action_Timestamp",
    lat."Name" AS "Action_Type",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM ((public."Logs" l
     JOIN public."Logs_Action_Types" lat ON ((l."ID_Action_Type" = lat."ID")))
     JOIN public."Staffs" s ON ((s."ID" = l."ID_Staff")));
    DROP VIEW public.logs_details;
       public          postgres    false    228    235    228    235    235    227    227    227    227    235         �            1259    34471    rooms_details    VIEW     �   CREATE VIEW public.rooms_details AS
 SELECT r."ID",
    r."Room_Number",
    r."Floor",
    r."Number_Of_Seats",
    d."Name" AS "Dormitory_Name"
   FROM (public."Rooms" r
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
     DROP VIEW public.rooms_details;
       public          postgres    false    231    223    223    231    231    231    231         �            1259    34475    staffs_details    VIEW     Q  CREATE VIEW public.staffs_details AS
 SELECT s."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    j."Name" AS "Job_Name",
    s."Contact_Number",
    d."Name" AS "Dormitory_Name"
   FROM ((public."Staffs" s
     JOIN public."Jobs" j ON ((s."ID_Job" = j."ID")))
     JOIN public."Dormitory" d ON ((d."ID" = s."ID_Dormitory")));
 !   DROP VIEW public.staffs_details;
       public          postgres    false    225    223    223    235    235    235    235    235    235    235    225         �            1259    34480    student_details    VIEW       CREATE VIEW public.student_details AS
 SELECT s."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    s."Birth_Date",
    s."Sex",
    s."Contact_Number",
    s."Email",
    u."Name" AS "University_Name",
    d."Name" AS "Dormitory_Name",
    sp."Name" AS "Specialties_Name"
   FROM (((public."Students" s
     JOIN public."Universities" u ON ((s."ID_Uni" = u."ID_Uni")))
     JOIN public."Dormitory" d ON ((s."ID_Speci" = d."ID")))
     JOIN public."Specialties" sp ON ((s."ID_Dormitory" = sp."ID_Spec")));
 "   DROP VIEW public.student_details;
       public          postgres    false    237    239    239    237    237    237    237    237    237    237    237    237    237    233    233    223    223         �            1259    34485    visits_details    VIEW     �   CREATE VIEW public.visits_details AS
 SELECT v."ID",
    v."Date_Time_Entered",
    v."Date_Time_Leaved",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Visits" v
     JOIN public."Students" s ON ((v."ID_Stud" = s."ID")));
 !   DROP VIEW public.visits_details;
       public          postgres    false    241    237    237    241    237    237    241    241         �           2604    34489    Check_Ins ID    DEFAULT     q   ALTER TABLE ONLY public."Check_Ins" ALTER COLUMN "ID" SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);
 ?   ALTER TABLE public."Check_Ins" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    222    221         �           2604    34490    Dormitory ID    DEFAULT     r   ALTER TABLE ONLY public."Dormitory" ALTER COLUMN "ID" SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);
 ?   ALTER TABLE public."Dormitory" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    224    223         �           2604    34491    Jobs ID    DEFAULT     g   ALTER TABLE ONLY public."Jobs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Job_ID_seq"'::regclass);
 :   ALTER TABLE public."Jobs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    226    225         �           2604    34492    Logs ID    DEFAULT     h   ALTER TABLE ONLY public."Logs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);
 :   ALTER TABLE public."Logs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    230    227         �           2604    34493    Logs_Action_Types ID    DEFAULT     �   ALTER TABLE ONLY public."Logs_Action_Types" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);
 G   ALTER TABLE public."Logs_Action_Types" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    229    228         �           2604    34494    Rooms ID    DEFAULT     j   ALTER TABLE ONLY public."Rooms" ALTER COLUMN "ID" SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);
 ;   ALTER TABLE public."Rooms" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    232    231         �           2604    34495    Specialties ID_Spec    DEFAULT     �   ALTER TABLE ONLY public."Specialties" ALTER COLUMN "ID_Spec" SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);
 F   ALTER TABLE public."Specialties" ALTER COLUMN "ID_Spec" DROP DEFAULT;
       public          postgres    false    234    233         �           2604    34496 	   Staffs ID    DEFAULT     k   ALTER TABLE ONLY public."Staffs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);
 <   ALTER TABLE public."Staffs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    236    235         �           2604    34497    Students ID    DEFAULT     p   ALTER TABLE ONLY public."Students" ALTER COLUMN "ID" SET DEFAULT nextval('public."Students_ID_seq"'::regclass);
 >   ALTER TABLE public."Students" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    238    237         �           2604    34498    Universities ID_Uni    DEFAULT     �   ALTER TABLE ONLY public."Universities" ALTER COLUMN "ID_Uni" SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);
 F   ALTER TABLE public."Universities" ALTER COLUMN "ID_Uni" DROP DEFAULT;
       public          postgres    false    240    239         �           2604    34499 	   Visits ID    DEFAULT     l   ALTER TABLE ONLY public."Visits" ALTER COLUMN "ID" SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);
 <   ALTER TABLE public."Visits" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    242    241         b          0    34410 	   Check_Ins 
   TABLE DATA           n   COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM stdin;
    public          postgres    false    221       4962.dat d          0    34414 	   Dormitory 
   TABLE DATA           P   COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    223       4964.dat f          0    34418    Jobs 
   TABLE DATA           H   COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM stdin;
    public          postgres    false    225       4966.dat h          0    34424    Logs 
   TABLE DATA           n   COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM stdin;
    public          postgres    false    227       4968.dat i          0    34429    Logs_Action_Types 
   TABLE DATA           J   COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM stdin;
    public          postgres    false    228       4969.dat l          0    34436    Rooms 
   TABLE DATA           b   COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM stdin;
    public          postgres    false    231       4972.dat n          0    34440    Specialties 
   TABLE DATA           B   COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM stdin;
    public          postgres    false    233       4974.dat p          0    34446    Staffs 
   TABLE DATA           �   COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM stdin;
    public          postgres    false    235       4976.dat r          0    34450    Students 
   TABLE DATA           �   COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM stdin;
    public          postgres    false    237       4978.dat t          0    34454    Universities 
   TABLE DATA           W   COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    239       4980.dat v          0    34458    Visits 
   TABLE DATA           \   COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM stdin;
    public          postgres    false    241       4982.dat �           0    0    Check_In_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);
          public          postgres    false    222         �           0    0    Dormitory_ID_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, false);
          public          postgres    false    224         �           0    0 
   Job_ID_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public."Job_ID_seq"', 1, false);
          public          postgres    false    226         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);
          public          postgres    false    229         �           0    0    Logs_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Logs_ID_seq"', 46, true);
          public          postgres    false    230         �           0    0    Rooms_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);
          public          postgres    false    232         �           0    0    Specialties_ID_Spec_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 39, true);
          public          postgres    false    234         �           0    0    Staff_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Staff_ID_seq"', 8, true);
          public          postgres    false    236         �           0    0    Students_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Students_ID_seq"', 1, false);
          public          postgres    false    238         �           0    0    Universities_ID_Uni_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 1, false);
          public          postgres    false    240         �           0    0    Visits_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);
          public          postgres    false    242         �           2606    34501    Check_Ins Check_Ins_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "Check_Ins_pkey";
       public            postgres    false    221         �           2606    34503    Dormitory Dormitory_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Dormitory"
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Dormitory" DROP CONSTRAINT "Dormitory_pkey";
       public            postgres    false    223         �           2606    34505    Jobs Job_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public."Jobs"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("ID");
 ;   ALTER TABLE ONLY public."Jobs" DROP CONSTRAINT "Job_pkey";
       public            postgres    false    225         �           2606    34507 (   Logs_Action_Types Logs_Action_Types_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Logs_Action_Types"
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY ("ID");
 V   ALTER TABLE ONLY public."Logs_Action_Types" DROP CONSTRAINT "Logs_Action_Types_pkey";
       public            postgres    false    228         �           2606    34509    Logs Logs_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY ("ID");
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "Logs_pkey";
       public            postgres    false    227         �           2606    34511    Rooms Rooms_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY ("ID");
 >   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "Rooms_pkey";
       public            postgres    false    231         �           2606    34513    Specialties Specialties_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Specialties"
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY ("ID_Spec");
 J   ALTER TABLE ONLY public."Specialties" DROP CONSTRAINT "Specialties_pkey";
       public            postgres    false    233         �           2606    34515    Staffs Staff_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY ("ID");
 ?   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "Staff_pkey";
       public            postgres    false    235         �           2606    34517    Students Students_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY ("ID");
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "Students_pkey";
       public            postgres    false    237         �           2606    34519    Universities Universities_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public."Universities"
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY ("ID_Uni");
 L   ALTER TABLE ONLY public."Universities" DROP CONSTRAINT "Universities_pkey";
       public            postgres    false    239         �           2606    34521    Visits Visits_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY ("ID");
 @   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "Visits_pkey";
       public            postgres    false    241         �           2620    34522 "   Staffs before_insert_hash_password    TRIGGER     �   CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 =   DROP TRIGGER before_insert_hash_password ON public."Staffs";
       public          postgres    false    235    273         �           2620    34523 "   Staffs before_update_hash_password    TRIGGER     �   CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();
 =   DROP TRIGGER before_update_hash_password ON public."Staffs";
       public          postgres    false    235    274         �           2606    34524    Logs FK_Action    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Action" FOREIGN KEY ("ID_Action_Type") REFERENCES public."Logs_Action_Types"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Action";
       public          postgres    false    228    4787    227         �           2606    34529    Students FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    237    4781         �           2606    34534    Staffs FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 A   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    235    223    4781         �           2606    34539    Rooms FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 @   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    4781    231    223         �           2606    34544    Staffs FK_Jobs    FK CONSTRAINT        ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY ("ID_Job") REFERENCES public."Jobs"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Jobs";
       public          postgres    false    235    225    4783         �           2606    34549    Check_Ins FK_Room    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Room";
       public          postgres    false    231    4789    221         �           2606    34554    Students FK_Specialites    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY ("ID_Speci") REFERENCES public."Specialties"("ID_Spec") NOT VALID;
 E   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Specialites";
       public          postgres    false    4791    233    237         �           2606    34559    Logs FK_Staff    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY ("ID_Staff") REFERENCES public."Staffs"("ID") NOT VALID;
 ;   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Staff";
       public          postgres    false    4793    235    227         �           2606    34564    Visits FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "FK_Student";
       public          postgres    false    4795    237    241         �           2606    34569    Check_Ins FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 B   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Student";
       public          postgres    false    237    221    4795         �           2606    34574    Students FK_University    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_University" FOREIGN KEY ("ID_Uni") REFERENCES public."Universities"("ID_Uni") NOT VALID;
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_University";
       public          postgres    false    4797    237    239                                                                                                                                                                                                                                                                                                                                                                                                                                        4962.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4964.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4966.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4968.dat                                                                                            0000600 0004000 0002000 00000003667 14672237122 0014306 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        31	2024-09-16 02:12:52.835511+03	2	8	[{"ID_Spec":32,"Name":"Name","Desc":"Desc"}]
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
\.


                                                                         4969.dat                                                                                            0000600 0004000 0002000 00000000525 14672237122 0014275 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Изменения в таблице	Информация о изменениях в таблице
2	Добавление в таблице	Информация о добавленой записе в таблице
3	Удаление из таблицы	Инфомрация об удаленных данных из таблицы
\.


                                                                                                                                                                           4972.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4974.dat                                                                                            0000600 0004000 0002000 00000000222 14672237122 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        33	ПОИТ	Desc
35	Инженерия искусственного интеллекта и машинного об	asdd
38	ПОИТ3	фыв
\.


                                                                                                                                                                                                                                                                                                                                                                              4976.dat                                                                                            0000600 0004000 0002000 00000000100 14672237122 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        8	\N	\N	\N	\N	\N	\N	Admin	b59c67bf196a4758191e42f76670ceba
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                4978.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4980.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4982.dat                                                                                            0000600 0004000 0002000 00000000005 14672237122 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000112414 14672237122 0015375 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
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
    INSERT INTO public."Logs" ("Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") 
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
-- Name: Check_Ins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Check_Ins" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "ID_Room" bigint,
    "Check_In_Timestamp" timestamp with time zone,
    "Check_Out_Timestamp" timestamp with time zone
);


ALTER TABLE public."Check_Ins" OWNER TO postgres;

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

ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."Check_Ins"."ID";


--
-- Name: Dormitory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Dormitory" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);


ALTER TABLE public."Dormitory" OWNER TO postgres;

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

ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public."Dormitory"."ID";


--
-- Name: Jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Jobs" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Acceses" json,
    "Description" text
);


ALTER TABLE public."Jobs" OWNER TO postgres;

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

ALTER SEQUENCE public."Job_ID_seq" OWNED BY public."Jobs"."ID";


--
-- Name: Logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Logs" (
    "ID" bigint NOT NULL,
    "Action_Timestamp" timestamp with time zone,
    "ID_Action_Type" bigint,
    "ID_Staff" bigint,
    "Action_Description" json
);


ALTER TABLE public."Logs" OWNER TO postgres;

--
-- Name: Logs_Action_Types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Logs_Action_Types" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);


ALTER TABLE public."Logs_Action_Types" OWNER TO postgres;

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

ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public."Logs_Action_Types"."ID";


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

ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public."Logs"."ID";


--
-- Name: Rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Rooms" (
    "ID" bigint NOT NULL,
    "Room_Number" bigint,
    "Floor" integer,
    "Number_Of_Seats" integer,
    "ID_Dormitory" bigint
);


ALTER TABLE public."Rooms" OWNER TO postgres;

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

ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public."Rooms"."ID";


--
-- Name: Specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Specialties" (
    "ID_Spec" bigint NOT NULL,
    "Name" character varying(50),
    "Desc" text
);


ALTER TABLE public."Specialties" OWNER TO postgres;

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

ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public."Specialties"."ID_Spec";


--
-- Name: Staffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Staffs" (
    "ID" bigint NOT NULL,
    "Surname" character varying(50),
    "Name" character varying(50),
    "Patronymic" character varying(50),
    "ID_Job" bigint,
    "Contact_Number" character varying(20),
    "ID_Dormitory" bigint,
    "Login" character varying(50),
    "Password" character varying(255)
);


ALTER TABLE public."Staffs" OWNER TO postgres;

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

ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public."Staffs"."ID";


--
-- Name: Students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Students" (
    "ID" bigint NOT NULL,
    "Surname" character varying(50),
    "Name" character varying(50),
    "Patronymic" character varying(50),
    "Birth_Date" date,
    "Sex" boolean,
    "Contact_Number" character varying(20),
    "Email" character varying(50),
    "ID_Uni" bigint,
    "ID_Speci" bigint,
    "ID_Dormitory" bigint
);


ALTER TABLE public."Students" OWNER TO postgres;

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

ALTER SEQUENCE public."Students_ID_seq" OWNED BY public."Students"."ID";


--
-- Name: Universities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Universities" (
    "ID_Uni" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);


ALTER TABLE public."Universities" OWNER TO postgres;

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

ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public."Universities"."ID_Uni";


--
-- Name: Visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Visits" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Date_Time_Entered" timestamp with time zone,
    "Date_Time_Leaved" timestamp with time zone
);


ALTER TABLE public."Visits" OWNER TO postgres;

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

ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public."Visits"."ID";


--
-- Name: check_ins_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.check_ins_details AS
 SELECT ci."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    r."Room_Number",
    ci."Check_In_Timestamp",
    ci."Check_Out_Timestamp",
    d."Name" AS "Dormitory_Name"
   FROM (((public."Check_Ins" ci
     JOIN public."Rooms" r ON ((ci."ID_Room" = r."ID")))
     JOIN public."Students" s ON ((ci."ID_Stud" = s."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));


ALTER VIEW public.check_ins_details OWNER TO postgres;

--
-- Name: logs_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.logs_details AS
 SELECT l."ID",
    l."Action_Timestamp",
    lat."Name" AS "Action_Type",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM ((public."Logs" l
     JOIN public."Logs_Action_Types" lat ON ((l."ID_Action_Type" = lat."ID")))
     JOIN public."Staffs" s ON ((s."ID" = l."ID_Staff")));


ALTER VIEW public.logs_details OWNER TO postgres;

--
-- Name: rooms_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rooms_details AS
 SELECT r."ID",
    r."Room_Number",
    r."Floor",
    r."Number_Of_Seats",
    d."Name" AS "Dormitory_Name"
   FROM (public."Rooms" r
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));


ALTER VIEW public.rooms_details OWNER TO postgres;

--
-- Name: staffs_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.staffs_details AS
 SELECT s."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    j."Name" AS "Job_Name",
    s."Contact_Number",
    d."Name" AS "Dormitory_Name"
   FROM ((public."Staffs" s
     JOIN public."Jobs" j ON ((s."ID_Job" = j."ID")))
     JOIN public."Dormitory" d ON ((d."ID" = s."ID_Dormitory")));


ALTER VIEW public.staffs_details OWNER TO postgres;

--
-- Name: student_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.student_details AS
 SELECT s."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    s."Birth_Date",
    s."Sex",
    s."Contact_Number",
    s."Email",
    u."Name" AS "University_Name",
    d."Name" AS "Dormitory_Name",
    sp."Name" AS "Specialties_Name"
   FROM (((public."Students" s
     JOIN public."Universities" u ON ((s."ID_Uni" = u."ID_Uni")))
     JOIN public."Dormitory" d ON ((s."ID_Speci" = d."ID")))
     JOIN public."Specialties" sp ON ((s."ID_Dormitory" = sp."ID_Spec")));


ALTER VIEW public.student_details OWNER TO postgres;

--
-- Name: visits_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.visits_details AS
 SELECT v."ID",
    v."Date_Time_Entered",
    v."Date_Time_Leaved",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Visits" v
     JOIN public."Students" s ON ((v."ID_Stud" = s."ID")));


ALTER VIEW public.visits_details OWNER TO postgres;

--
-- Name: Check_Ins ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins" ALTER COLUMN "ID" SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);


--
-- Name: Dormitory ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dormitory" ALTER COLUMN "ID" SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);


--
-- Name: Jobs ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Jobs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Job_ID_seq"'::regclass);


--
-- Name: Logs ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);


--
-- Name: Logs_Action_Types ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs_Action_Types" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);


--
-- Name: Rooms ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rooms" ALTER COLUMN "ID" SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);


--
-- Name: Specialties ID_Spec; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Specialties" ALTER COLUMN "ID_Spec" SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);


--
-- Name: Staffs ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Staffs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);


--
-- Name: Students ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students" ALTER COLUMN "ID" SET DEFAULT nextval('public."Students_ID_seq"'::regclass);


--
-- Name: Universities ID_Uni; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Universities" ALTER COLUMN "ID_Uni" SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);


--
-- Name: Visits ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Visits" ALTER COLUMN "ID" SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);


--
-- Data for Name: Check_Ins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM stdin;
\.
COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM '$$PATH$$/4962.dat';

--
-- Data for Name: Dormitory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM stdin;
\.
COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM '$$PATH$$/4964.dat';

--
-- Data for Name: Jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM stdin;
\.
COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM '$$PATH$$/4966.dat';

--
-- Data for Name: Logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM stdin;
\.
COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM '$$PATH$$/4968.dat';

--
-- Data for Name: Logs_Action_Types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM stdin;
\.
COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM '$$PATH$$/4969.dat';

--
-- Data for Name: Rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM stdin;
\.
COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM '$$PATH$$/4972.dat';

--
-- Data for Name: Specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM stdin;
\.
COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM '$$PATH$$/4974.dat';

--
-- Data for Name: Staffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM stdin;
\.
COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM '$$PATH$$/4976.dat';

--
-- Data for Name: Students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM stdin;
\.
COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM '$$PATH$$/4978.dat';

--
-- Data for Name: Universities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM stdin;
\.
COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM '$$PATH$$/4980.dat';

--
-- Data for Name: Visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM stdin;
\.
COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM '$$PATH$$/4982.dat';

--
-- Name: Check_In_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);


--
-- Name: Dormitory_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, false);


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

SELECT pg_catalog.setval('public."Logs_ID_seq"', 46, true);


--
-- Name: Rooms_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);


--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 39, true);


--
-- Name: Staff_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Staff_ID_seq"', 8, true);


--
-- Name: Students_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Students_ID_seq"', 1, false);


--
-- Name: Universities_ID_Uni_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 1, false);


--
-- Name: Visits_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);


--
-- Name: Check_Ins Check_Ins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY ("ID");


--
-- Name: Dormitory Dormitory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dormitory"
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY ("ID");


--
-- Name: Jobs Job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Jobs"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("ID");


--
-- Name: Logs_Action_Types Logs_Action_Types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs_Action_Types"
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY ("ID");


--
-- Name: Logs Logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY ("ID");


--
-- Name: Rooms Rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY ("ID");


--
-- Name: Specialties Specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Specialties"
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY ("ID_Spec");


--
-- Name: Staffs Staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY ("ID");


--
-- Name: Students Students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY ("ID");


--
-- Name: Universities Universities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Universities"
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY ("ID_Uni");


--
-- Name: Visits Visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY ("ID");


--
-- Name: Staffs before_insert_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password();


--
-- Name: Staffs before_update_hash_password; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();


--
-- Name: Logs FK_Action; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Action" FOREIGN KEY ("ID_Action_Type") REFERENCES public."Logs_Action_Types"("ID") NOT VALID;


--
-- Name: Students FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;


--
-- Name: Staffs FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;


--
-- Name: Rooms FK_Dormitory; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;


--
-- Name: Staffs FK_Jobs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY ("ID_Job") REFERENCES public."Jobs"("ID") NOT VALID;


--
-- Name: Check_Ins FK_Room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;


--
-- Name: Students FK_Specialites; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY ("ID_Speci") REFERENCES public."Specialties"("ID_Spec") NOT VALID;


--
-- Name: Logs FK_Staff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY ("ID_Staff") REFERENCES public."Staffs"("ID") NOT VALID;


--
-- Name: Visits FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Check_Ins FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Students FK_University; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_University" FOREIGN KEY ("ID_Uni") REFERENCES public."Universities"("ID_Uni") NOT VALID;


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
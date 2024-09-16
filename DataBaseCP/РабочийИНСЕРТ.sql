PGDMP  6                    |         	   Dormitory    16.4    16.4 y    |           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            }           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ~           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    33998 	   Dormitory    DATABASE     �   CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';
    DROP DATABASE "Dormitory";
                postgres    false                        3079    33999    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false            �           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    2                       1255    34316 <   check_user_credentials(character varying, character varying)    FUNCTION     u  CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name text, patronymic character varying, id bigint, dormitoryname bigint, rolename character varying, acceses json)
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
       public          postgres    false            #           1255    34037 %   compare_jsons(json, json, text, text)    FUNCTION     �  CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes jsonb := '[]'::jsonb;
    obj1 jsonb;
    obj2 jsonb;
    key_value text;
    change jsonb;
    json_key text;
    keys text[];
BEGIN
    FOR obj1 IN SELECT * FROM jsonb_array_elements(json1::jsonb) LOOP
        key_value := obj1->>key_column;
        obj2 := (SELECT value FROM jsonb_array_elements(json2::jsonb) value WHERE value->>key_column = key_value::text);
        
        IF obj2 IS NOT NULL THEN
            change := '{}'::jsonb;
            keys := ARRAY(SELECT jsonb_object_keys(obj1));
            FOREACH json_key IN ARRAY keys LOOP
                IF obj1->>json_key <> obj2->>json_key THEN
                    change := jsonb_set(change, '{' || json_key || '}', to_jsonb(obj1->>json_key || ' -> ' || obj2->>json_key));
                END IF;
            END LOOP;
            changes := jsonb_set(changes, '{' || array_length(jsonb_array_elements(changes), 1) || '}', change);
        END IF;
    END LOOP;
    
    RETURN jsonb_build_object('table', table_name, 'changes', changes)::json;
END;
$$;
 ^   DROP FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text);
       public          postgres    false            $           1255    34038 &   delete_from_table(text, text, integer) 	   PROCEDURE     <  CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    delete_query TEXT;
BEGIN
    delete_query := 'DELETE FROM ' || delete_table_name || ' WHERE ' || id_column || ' = ' || id_value;
    EXECUTE delete_query;
END;
$$;
 l   DROP PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value integer);
       public          postgres    false            %           1255    34039    get_all_tables()    FUNCTION     
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
       public          postgres    false            &           1255    34040    get_all_views()    FUNCTION       CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
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
       public          postgres    false            '           1255    34318    get_column_info(text, text)    FUNCTION     �  CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
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
       public          postgres    false            (           1255    34041    get_foreign_keys(text)    FUNCTION       CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
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
       public          postgres    false                       1255    34042    get_primary_key_column(text)    FUNCTION     k  CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
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
       public          postgres    false                       1255    34043    get_table_columns(text)    FUNCTION       CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
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
       public          postgres    false                       1255    34311    hash_password()    FUNCTION     �   CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."Password" := MD5(NEW."Password");
    RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false                       1255    34313    hash_password_update()    FUNCTION     �   CREATE FUNCTION public.hash_password_update() RETURNS trigger
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
       public          postgres    false                       1255    34044 &   insert_into_logs(bigint, bigint, json) 	   PROCEDURE     D  CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Logs" ("Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;
 p   DROP PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json);
       public          postgres    false                       1255    34331 #   insert_into_specialties(text, text)    FUNCTION     �   CREATE FUNCTION public.insert_into_specialties(id text, table_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, '{"Desc":"Desc","Name":"Name"}');
END;
$$;
 H   DROP FUNCTION public.insert_into_specialties(id text, table_name text);
       public          postgres    false                       1255    34333 )   insert_into_specialties(text, text, json)    FUNCTION     �   CREATE FUNCTION public.insert_into_specialties(id text, table_name text, json_data json) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id, table_name, json_data);
END;
$$;
 X   DROP FUNCTION public.insert_into_specialties(id text, table_name text, json_data json);
       public          postgres    false                       1255    34334 )   insert_into_specialties(text, text, text)    FUNCTION     �   CREATE FUNCTION public.insert_into_specialties(id text, table_name text, string text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL insert_into_table(id::bigint, table_name, string::json);
END;
$$;
 U   DROP FUNCTION public.insert_into_specialties(id text, table_name text, string text);
       public          postgres    false            *           1255    34332    insert_into_table(bigint, text) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	insert_columns json='{"Desc":"Desc","Name":"Name"}'::json;
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
	 CALL insert_into_logs(2, staff_id, logJson);        
END;
$$;
 X   DROP PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text);
       public          postgres    false            )           1255    34325 %   insert_into_table(bigint, text, json) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json)
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
	 CALL insert_into_logs(2, staff_id, logJson);        
END;
$$;
 p   DROP PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns json);
       public          postgres    false            +           1255    34335 %   insert_into_table(bigint, text, text) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns text)
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
    FROM json_each_text(insert_columns::json)
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
	 CALL insert_into_logs(2, staff_id, logJson);        
END;
$$;
 p   DROP PROCEDURE public.insert_into_table(IN staff_id bigint, IN insert_table_name text, IN insert_columns text);
       public          postgres    false                       1255    34046 '   update_table(text, text, integer, json) 	   PROCEDURE     K  CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value integer, IN update_columns json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    update_column_name TEXT;
    column_value TEXT;
    update_query TEXT;
BEGIN
    update_query := 'UPDATE public."' || update_table_name || '" SET ';
    
    FOR update_column_name, column_value IN
        SELECT "key", "value"
        FROM json_each_text(update_columns)
    LOOP
        update_query := update_query || update_column_name || ' = ' || quote_literal(column_value) || ', ';
    END LOOP;
    
    -- Удаляем последнюю запятую и пробел
    update_query := left(update_query, length(update_query) - 2);
    
    update_query := update_query || ' WHERE ' || id_column || ' = ' || id_value;
    
    EXECUTE update_query;
END;
$$;
    DROP PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value integer, IN update_columns json);
       public          postgres    false            �            1259    34047 	   Check_Ins    TABLE     �   CREATE TABLE public."Check_Ins" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "ID_Room" bigint,
    "Check_In_Timestamp" timestamp with time zone,
    "Check_Out_Timestamp" timestamp with time zone
);
    DROP TABLE public."Check_Ins";
       public         heap    postgres    false            �            1259    34050    Check_In_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Check_In_ID_seq";
       public          postgres    false    221            �           0    0    Check_In_ID_seq    SEQUENCE OWNED BY     J   ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."Check_Ins"."ID";
          public          postgres    false    222            �            1259    34063 	   Dormitory    TABLE     �   CREATE TABLE public."Dormitory" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
    DROP TABLE public."Dormitory";
       public         heap    postgres    false            �            1259    34066    Dormitory_ID_seq    SEQUENCE     {   CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public."Dormitory_ID_seq";
       public          postgres    false    223            �           0    0    Dormitory_ID_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public."Dormitory"."ID";
          public          postgres    false    224            �            1259    34077    Jobs    TABLE     �   CREATE TABLE public."Jobs" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Acceses" json,
    "Description" text
);
    DROP TABLE public."Jobs";
       public         heap    postgres    false            �            1259    34082 
   Job_ID_seq    SEQUENCE     u   CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public."Job_ID_seq";
       public          postgres    false    225            �           0    0 
   Job_ID_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public."Job_ID_seq" OWNED BY public."Jobs"."ID";
          public          postgres    false    226            �            1259    34083    Logs    TABLE     �   CREATE TABLE public."Logs" (
    "ID" bigint NOT NULL,
    "Action_Timestamp" timestamp with time zone,
    "ID_Action_Type" bigint,
    "ID_Staff" bigint,
    "Action_Description" json
);
    DROP TABLE public."Logs";
       public         heap    postgres    false            �            1259    34088    Logs_Action_Types    TABLE     �   CREATE TABLE public."Logs_Action_Types" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);
 '   DROP TABLE public."Logs_Action_Types";
       public         heap    postgres    false            �            1259    34093    Logs_Action_Types_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Logs_Action_Types_ID_seq";
       public          postgres    false    228            �           0    0    Logs_Action_Types_ID_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public."Logs_Action_Types"."ID";
          public          postgres    false    229            �            1259    34094    Logs_ID_seq    SEQUENCE     v   CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."Logs_ID_seq";
       public          postgres    false    227            �           0    0    Logs_ID_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public."Logs"."ID";
          public          postgres    false    230            �            1259    34105    Rooms    TABLE     �   CREATE TABLE public."Rooms" (
    "ID" bigint NOT NULL,
    "Room_Number" bigint,
    "Floor" integer,
    "Number_Of_Seats" integer,
    "ID_Dormitory" bigint
);
    DROP TABLE public."Rooms";
       public         heap    postgres    false            �            1259    34108    Rooms_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Rooms_ID_seq";
       public          postgres    false    231            �           0    0    Rooms_ID_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public."Rooms"."ID";
          public          postgres    false    232            �            1259    34109    Specialties    TABLE     x   CREATE TABLE public."Specialties" (
    "ID_Spec" bigint NOT NULL,
    "Name" character varying(50),
    "Desc" text
);
 !   DROP TABLE public."Specialties";
       public         heap    postgres    false            �            1259    34114    Specialties_ID_Spec_seq    SEQUENCE     �   CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Specialties_ID_Spec_seq";
       public          postgres    false    233            �           0    0    Specialties_ID_Spec_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public."Specialties"."ID_Spec";
          public          postgres    false    234            �            1259    34115    Staffs    TABLE     P  CREATE TABLE public."Staffs" (
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
       public         heap    postgres    false            �            1259    34118    Staff_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Staff_ID_seq";
       public          postgres    false    235            �           0    0    Staff_ID_seq    SEQUENCE OWNED BY     D   ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public."Staffs"."ID";
          public          postgres    false    236            �            1259    34119    Students    TABLE     l  CREATE TABLE public."Students" (
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
       public         heap    postgres    false            �            1259    34122    Students_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Students_ID_seq";
       public          postgres    false    237            �           0    0    Students_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Students_ID_seq" OWNED BY public."Students"."ID";
          public          postgres    false    238            �            1259    34123    Universities    TABLE     �   CREATE TABLE public."Universities" (
    "ID_Uni" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
 "   DROP TABLE public."Universities";
       public         heap    postgres    false            �            1259    34126    Universities_ID_Uni_seq    SEQUENCE     �   CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Universities_ID_Uni_seq";
       public          postgres    false    239            �           0    0    Universities_ID_Uni_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public."Universities"."ID_Uni";
          public          postgres    false    240            �            1259    34127    Visits    TABLE     �   CREATE TABLE public."Visits" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Date_Time_Entered" timestamp with time zone,
    "Date_Time_Leaved" timestamp with time zone
);
    DROP TABLE public."Visits";
       public         heap    postgres    false            �            1259    34130    Visits_ID_seq    SEQUENCE     x   CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Visits_ID_seq";
       public          postgres    false    241            �           0    0    Visits_ID_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public."Visits"."ID";
          public          postgres    false    242            �            1259    34131    check_ins_details    VIEW     �  CREATE VIEW public.check_ins_details AS
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
       public          postgres    false    237    237    237    231    231    231    223    223    221    221    221    221    221    237            �            1259    34145    logs_details    VIEW     D  CREATE VIEW public.logs_details AS
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
       public          postgres    false    227    227    228    228    235    235    235    235    227    227            �            1259    34157    rooms_details    VIEW     �   CREATE VIEW public.rooms_details AS
 SELECT r."ID",
    r."Room_Number",
    r."Floor",
    r."Number_Of_Seats",
    d."Name" AS "Dormitory_Name"
   FROM (public."Rooms" r
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
     DROP VIEW public.rooms_details;
       public          postgres    false    231    223    223    231    231    231    231            �            1259    34161    staffs_details    VIEW     Q  CREATE VIEW public.staffs_details AS
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
       public          postgres    false    235    223    223    225    225    235    235    235    235    235    235            �            1259    34165    student_details    VIEW       CREATE VIEW public.student_details AS
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
       public          postgres    false    237    233    233    223    223    237    237    237    237    237    237    239    239    237    237    237    237            �            1259    34170    visits_details    VIEW     �   CREATE VIEW public.visits_details AS
 SELECT v."ID",
    v."Date_Time_Entered",
    v."Date_Time_Leaved",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Visits" v
     JOIN public."Students" s ON ((v."ID_Stud" = s."ID")));
 !   DROP VIEW public.visits_details;
       public          postgres    false    237    241    241    241    241    237    237    237            �           2604    34174    Check_Ins ID    DEFAULT     q   ALTER TABLE ONLY public."Check_Ins" ALTER COLUMN "ID" SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);
 ?   ALTER TABLE public."Check_Ins" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    222    221            �           2604    34177    Dormitory ID    DEFAULT     r   ALTER TABLE ONLY public."Dormitory" ALTER COLUMN "ID" SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);
 ?   ALTER TABLE public."Dormitory" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    224    223            �           2604    34180    Jobs ID    DEFAULT     g   ALTER TABLE ONLY public."Jobs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Job_ID_seq"'::regclass);
 :   ALTER TABLE public."Jobs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    226    225            �           2604    34181    Logs ID    DEFAULT     h   ALTER TABLE ONLY public."Logs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);
 :   ALTER TABLE public."Logs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    230    227            �           2604    34182    Logs_Action_Types ID    DEFAULT     �   ALTER TABLE ONLY public."Logs_Action_Types" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);
 G   ALTER TABLE public."Logs_Action_Types" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    229    228            �           2604    34185    Rooms ID    DEFAULT     j   ALTER TABLE ONLY public."Rooms" ALTER COLUMN "ID" SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);
 ;   ALTER TABLE public."Rooms" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    232    231            �           2604    34186    Specialties ID_Spec    DEFAULT     �   ALTER TABLE ONLY public."Specialties" ALTER COLUMN "ID_Spec" SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);
 F   ALTER TABLE public."Specialties" ALTER COLUMN "ID_Spec" DROP DEFAULT;
       public          postgres    false    234    233            �           2604    34187 	   Staffs ID    DEFAULT     k   ALTER TABLE ONLY public."Staffs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);
 <   ALTER TABLE public."Staffs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    236    235            �           2604    34188    Students ID    DEFAULT     p   ALTER TABLE ONLY public."Students" ALTER COLUMN "ID" SET DEFAULT nextval('public."Students_ID_seq"'::regclass);
 >   ALTER TABLE public."Students" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    238    237            �           2604    34189    Universities ID_Uni    DEFAULT     �   ALTER TABLE ONLY public."Universities" ALTER COLUMN "ID_Uni" SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);
 F   ALTER TABLE public."Universities" ALTER COLUMN "ID_Uni" DROP DEFAULT;
       public          postgres    false    240    239            �           2604    34190 	   Visits ID    DEFAULT     l   ALTER TABLE ONLY public."Visits" ALTER COLUMN "ID" SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);
 <   ALTER TABLE public."Visits" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    242    241            d          0    34047 	   Check_Ins 
   TABLE DATA           n   COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM stdin;
    public          postgres    false    221   (�       f          0    34063 	   Dormitory 
   TABLE DATA           P   COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    223   E�       h          0    34077    Jobs 
   TABLE DATA           H   COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM stdin;
    public          postgres    false    225   b�       j          0    34083    Logs 
   TABLE DATA           n   COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM stdin;
    public          postgres    false    227   �       k          0    34088    Logs_Action_Types 
   TABLE DATA           J   COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM stdin;
    public          postgres    false    228   ]�       n          0    34105    Rooms 
   TABLE DATA           b   COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM stdin;
    public          postgres    false    231   �       p          0    34109    Specialties 
   TABLE DATA           B   COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM stdin;
    public          postgres    false    233   !�       r          0    34115    Staffs 
   TABLE DATA           �   COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM stdin;
    public          postgres    false    235   ��       t          0    34119    Students 
   TABLE DATA           �   COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM stdin;
    public          postgres    false    237   �       v          0    34123    Universities 
   TABLE DATA           W   COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    239   �       x          0    34127    Visits 
   TABLE DATA           \   COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM stdin;
    public          postgres    false    241   �       �           0    0    Check_In_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);
          public          postgres    false    222            �           0    0    Dormitory_ID_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, false);
          public          postgres    false    224            �           0    0 
   Job_ID_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public."Job_ID_seq"', 1, false);
          public          postgres    false    226            �           0    0    Logs_Action_Types_ID_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);
          public          postgres    false    229            �           0    0    Logs_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Logs_ID_seq"', 32, true);
          public          postgres    false    230            �           0    0    Rooms_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);
          public          postgres    false    232            �           0    0    Specialties_ID_Spec_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 33, true);
          public          postgres    false    234            �           0    0    Staff_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Staff_ID_seq"', 8, true);
          public          postgres    false    236            �           0    0    Students_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Students_ID_seq"', 1, false);
          public          postgres    false    238            �           0    0    Universities_ID_Uni_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 1, false);
          public          postgres    false    240            �           0    0    Visits_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);
          public          postgres    false    242            �           2606    34192    Check_Ins Check_Ins_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "Check_Ins_pkey";
       public            postgres    false    221            �           2606    34198    Dormitory Dormitory_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Dormitory"
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Dormitory" DROP CONSTRAINT "Dormitory_pkey";
       public            postgres    false    223            �           2606    34204    Jobs Job_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public."Jobs"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("ID");
 ;   ALTER TABLE ONLY public."Jobs" DROP CONSTRAINT "Job_pkey";
       public            postgres    false    225            �           2606    34206 (   Logs_Action_Types Logs_Action_Types_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Logs_Action_Types"
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY ("ID");
 V   ALTER TABLE ONLY public."Logs_Action_Types" DROP CONSTRAINT "Logs_Action_Types_pkey";
       public            postgres    false    228            �           2606    34208    Logs Logs_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY ("ID");
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "Logs_pkey";
       public            postgres    false    227            �           2606    34214    Rooms Rooms_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY ("ID");
 >   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "Rooms_pkey";
       public            postgres    false    231            �           2606    34216    Specialties Specialties_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Specialties"
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY ("ID_Spec");
 J   ALTER TABLE ONLY public."Specialties" DROP CONSTRAINT "Specialties_pkey";
       public            postgres    false    233            �           2606    34218    Staffs Staff_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY ("ID");
 ?   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "Staff_pkey";
       public            postgres    false    235            �           2606    34220    Students Students_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY ("ID");
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "Students_pkey";
       public            postgres    false    237            �           2606    34222    Universities Universities_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public."Universities"
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY ("ID_Uni");
 L   ALTER TABLE ONLY public."Universities" DROP CONSTRAINT "Universities_pkey";
       public            postgres    false    239            �           2606    34224    Visits Visits_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY ("ID");
 @   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "Visits_pkey";
       public            postgres    false    241            �           2620    34312 "   Staffs before_insert_hash_password    TRIGGER     �   CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 =   DROP TRIGGER before_insert_hash_password ON public."Staffs";
       public          postgres    false    273    235            �           2620    34314 "   Staffs before_update_hash_password    TRIGGER     �   CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();
 =   DROP TRIGGER before_update_hash_password ON public."Staffs";
       public          postgres    false    235    274            �           2606    34225    Logs FK_Action    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Action" FOREIGN KEY ("ID_Action_Type") REFERENCES public."Logs_Action_Types"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Action";
       public          postgres    false    228    227    4789            �           2606    34230    Students FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    237    223    4783            �           2606    34235    Staffs FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 A   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    235    223    4783            �           2606    34240    Rooms FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 @   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    223    231    4783            �           2606    34245    Staffs FK_Jobs    FK CONSTRAINT        ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY ("ID_Job") REFERENCES public."Jobs"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Jobs";
       public          postgres    false    225    4785    235            �           2606    34255    Check_Ins FK_Room    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Room";
       public          postgres    false    4791    231    221            �           2606    34265    Students FK_Specialites    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY ("ID_Speci") REFERENCES public."Specialties"("ID_Spec") NOT VALID;
 E   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Specialites";
       public          postgres    false    237    4793    233            �           2606    34270    Logs FK_Staff    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY ("ID_Staff") REFERENCES public."Staffs"("ID") NOT VALID;
 ;   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Staff";
       public          postgres    false    227    235    4795            �           2606    34285    Visits FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "FK_Student";
       public          postgres    false    237    241    4797            �           2606    34295    Check_Ins FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 B   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Student";
       public          postgres    false    4797    221    237            �           2606    34305    Students FK_University    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_University" FOREIGN KEY ("ID_Uni") REFERENCES public."Universities"("ID_Uni") NOT VALID;
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_University";
       public          postgres    false    237    239    4799            d      x������ � �      f      x������ � �      h      x������ � �      j   �  x��ձ��1��}
ԕ���9��̷��0BuD:��LwO�G���R#O��GI�o��=�{o�V���st{Kr����=|��x�vZ�������i�|�N��������x�񢱺�al62�
�vϮ� �<��|�|�a�L�Yxs�8֧m�pp�1 �.�n2�MS�+�7�T����J�.�2gS���ְT��"b�ͺ�������vL��&�V���X�[�9�X��{-��޸Q~{�\x�Eb׈s�|�U0�#��k��αJ��fĖP�E2U3؛�y�=��'�*��� �|���U2ؓ�k5̈́�#�d�'��F�i�<T��u2Q��l˴��U1����ܙ(������E��ld�%LUl-���i�`�b�b���4z^5�b07���is�R:j����:���k�*�[1^U��*�.J�1��:}'�_2�������ϭ���ǿ��&�      k   �   x�����0Dc]�����8 ! ���f�D{�R`�MB��v��;�.��C@,���G�mE�'�#B���lMT,y���uY8��(�E��s��jŋ���.Y:\�ӡ��~aV�Jt�~�����hU�Z�a�MV3y�e�      n      x������ � �      p   j   x�M�!�@DQ�{B���Gs!+Q\	'��������lGMs=�<`����c�ጎ�3
��� �@�Q 
D�(�@���)p
�S<q��X���tfW      r   9   x�����CG�)��y�I���f�Ii��f�&�����&Fi�ff�ɩI�\1z\\\ �      t      x������ � �      v      x������ � �      x      x������ � �     
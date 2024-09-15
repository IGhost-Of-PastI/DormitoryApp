toc.dat                                                                                             0000600 0004000 0002000 00000165741 14671431351 0014462 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   -                    |         	   Dormitory    16.4    16.4 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         �           1262    33998 	   Dormitory    DATABASE     �   CREATE DATABASE "Dormitory" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Belarusian_Belarus.1251';
    DROP DATABASE "Dormitory";
                postgres    false                     3079    33999    pldbgapi 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA public;
    DROP EXTENSION pldbgapi;
                   false         �           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                        false    2                     1255    34316 <   check_user_credentials(character varying, character varying)    FUNCTION     u  CREATE FUNCTION public.check_user_credentials(p_username character varying, p_password character varying) RETURNS TABLE(surname character varying, name text, patronymic character varying, id bigint, dormitoryname bigint, rolename character varying, acceses json)
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
       public          postgres    false         1           1255    34037 %   compare_jsons(json, json, text, text)    FUNCTION     �  CREATE FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) RETURNS json
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
       public          postgres    false         2           1255    34038 &   delete_from_table(text, text, integer) 	   PROCEDURE     <  CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value integer)
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
       public          postgres    false         3           1255    34039    get_all_tables()    FUNCTION     
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
       public          postgres    false         4           1255    34040    get_all_views()    FUNCTION       CREATE FUNCTION public.get_all_views() RETURNS TABLE(view_name text)
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
       public          postgres    false         5           1255    34318    get_column_info(text, text)    FUNCTION     �  CREATE FUNCTION public.get_column_info(table_name text, column_name text) RETURNS TABLE(column_type text, character_maximum_length integer, is_nullable boolean)
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
       public          postgres    false         6           1255    34041    get_foreign_keys(text)    FUNCTION       CREATE FUNCTION public.get_foreign_keys(p_table_name text) RETURNS TABLE(constraint_name text, column_name text, referenced_table text, referenced_column text)
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
       public          postgres    false                    1255    34042    get_primary_key_column(text)    FUNCTION     k  CREATE FUNCTION public.get_primary_key_column(table_name text) RETURNS text
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
       public          postgres    false                    1255    34043    get_table_columns(text)    FUNCTION       CREATE FUNCTION public.get_table_columns(p_table_name text) RETURNS TABLE(column_name text)
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
       public          postgres    false         -           1255    34311    hash_password()    FUNCTION     �   CREATE FUNCTION public.hash_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Password := MD5(NEW.Password);
    RETURN NEW;
END;
$$;
 &   DROP FUNCTION public.hash_password();
       public          postgres    false         .           1255    34313    hash_password_update()    FUNCTION     �   CREATE FUNCTION public.hash_password_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.Password IS DISTINCT FROM OLD.Password THEN
        NEW.Password := MD5(NEW.Password);
    END IF;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.hash_password_update();
       public          postgres    false                    1255    34044 &   insert_into_logs(bigint, bigint, json) 	   PROCEDURE     D  CREATE PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Logs" ("Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") 
	VALUES (now(), action_id, employee_id, action_description);
END;
$$;
 p   DROP PROCEDURE public.insert_into_logs(IN action_id bigint, IN employee_id bigint, IN action_description json);
       public          postgres    false         !           1255    34045    insert_into_table(text, json) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_into_table(IN insert_table_name text, IN insert_columns json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    "column_name" Text;
	"column_value" text;
	column_names TEXT;
    column_values TEXT;
    insert_query TEXT;
BEGIN
    column_names := '';
    column_values := '';

    FOR "column_name", "column_value" IN
        SELECT "key", "value"
        FROM json_each_text(insert_columns)
    LOOP
        column_names := column_names || "column_name" || ', ';
        column_values := column_values || quote_literal(column_value) || ', ';
    END LOOP;

    -- Удаляем последнюю запятую и пробел
    column_names := left(column_names, length(column_names) - 2);
    column_values := left(column_values, length(column_values) - 2);

    insert_query := 'INSERT INTO ' || insert_table_name || ' (' || column_names || ') VALUES (' || column_values || ')';
    EXECUTE insert_query;
END;
$$;
 \   DROP PROCEDURE public.insert_into_table(IN insert_table_name text, IN insert_columns json);
       public          postgres    false         &           1255    34046 '   update_table(text, text, integer, json) 	   PROCEDURE     K  CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value integer, IN update_columns json)
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
       public          postgres    false         �            1259    34047 	   Check_Ins    TABLE     �   CREATE TABLE public."Check_Ins" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "ID_Room" bigint,
    "Check_In_Timestamp" timestamp with time zone,
    "Check_Out_Timestamp" timestamp with time zone
);
    DROP TABLE public."Check_Ins";
       public         heap    postgres    false         �            1259    34050    Check_In_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Check_In_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Check_In_ID_seq";
       public          postgres    false    221         �           0    0    Check_In_ID_seq    SEQUENCE OWNED BY     J   ALTER SEQUENCE public."Check_In_ID_seq" OWNED BY public."Check_Ins"."ID";
          public          postgres    false    222         �            1259    34051    Complaints_And_Suggestions    TABLE     �   CREATE TABLE public."Complaints_And_Suggestions" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Description" text,
    "Date_Of_Submission" timestamp with time zone,
    "ID_Status" bigint
);
 0   DROP TABLE public."Complaints_And_Suggestions";
       public         heap    postgres    false         �            1259    34056 !   Complaints_And_Suggestions_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Complaints_And_Suggestions_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public."Complaints_And_Suggestions_ID_seq";
       public          postgres    false    223         �           0    0 !   Complaints_And_Suggestions_ID_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public."Complaints_And_Suggestions_ID_seq" OWNED BY public."Complaints_And_Suggestions"."ID";
          public          postgres    false    224         �            1259    34057 !   Complaints_And_Suggestions_Status    TABLE     �   CREATE TABLE public."Complaints_And_Suggestions_Status" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);
 7   DROP TABLE public."Complaints_And_Suggestions_Status";
       public         heap    postgres    false         �            1259    34062 (   Complaints_And_Suggestions_Status_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq";
       public          postgres    false    225         �           0    0 (   Complaints_And_Suggestions_Status_ID_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq" OWNED BY public."Complaints_And_Suggestions_Status"."ID";
          public          postgres    false    226         �            1259    34063 	   Dormitory    TABLE     �   CREATE TABLE public."Dormitory" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
    DROP TABLE public."Dormitory";
       public         heap    postgres    false         �            1259    34066    Dormitory_ID_seq    SEQUENCE     {   CREATE SEQUENCE public."Dormitory_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public."Dormitory_ID_seq";
       public          postgres    false    227         �           0    0    Dormitory_ID_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public."Dormitory_ID_seq" OWNED BY public."Dormitory"."ID";
          public          postgres    false    228         �            1259    34067    Furniture_And_Equipment    TABLE     �   CREATE TABLE public."Furniture_And_Equipment" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "ID_Room" bigint,
    "ID_Status" bigint
);
 -   DROP TABLE public."Furniture_And_Equipment";
       public         heap    postgres    false         �            1259    34070    Furniture_And_Equipment_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Furniture_And_Equipment_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public."Furniture_And_Equipment_ID_seq";
       public          postgres    false    229         �           0    0    Furniture_And_Equipment_ID_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public."Furniture_And_Equipment_ID_seq" OWNED BY public."Furniture_And_Equipment"."ID";
          public          postgres    false    230         �            1259    34071    Furniture_And_Equipment_Status    TABLE     �   CREATE TABLE public."Furniture_And_Equipment_Status" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);
 4   DROP TABLE public."Furniture_And_Equipment_Status";
       public         heap    postgres    false         �            1259    34076 %   Furniture_And_Equipment_Status_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Furniture_And_Equipment_Status_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE public."Furniture_And_Equipment_Status_ID_seq";
       public          postgres    false    231         �           0    0 %   Furniture_And_Equipment_Status_ID_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."Furniture_And_Equipment_Status_ID_seq" OWNED BY public."Furniture_And_Equipment_Status"."ID";
          public          postgres    false    232         �            1259    34077    Jobs    TABLE     �   CREATE TABLE public."Jobs" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Acceses" json,
    "Description" text
);
    DROP TABLE public."Jobs";
       public         heap    postgres    false         �            1259    34082 
   Job_ID_seq    SEQUENCE     u   CREATE SEQUENCE public."Job_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public."Job_ID_seq";
       public          postgres    false    233         �           0    0 
   Job_ID_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public."Job_ID_seq" OWNED BY public."Jobs"."ID";
          public          postgres    false    234         �            1259    34083    Logs    TABLE     �   CREATE TABLE public."Logs" (
    "ID" bigint NOT NULL,
    "Action_Timestamp" timestamp with time zone,
    "ID_Action_Type" bigint,
    "ID_Staff" bigint,
    "Action_Description" json
);
    DROP TABLE public."Logs";
       public         heap    postgres    false         �            1259    34088    Logs_Action_Types    TABLE     �   CREATE TABLE public."Logs_Action_Types" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);
 '   DROP TABLE public."Logs_Action_Types";
       public         heap    postgres    false         �            1259    34093    Logs_Action_Types_ID_seq    SEQUENCE     �   CREATE SEQUENCE public."Logs_Action_Types_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Logs_Action_Types_ID_seq";
       public          postgres    false    236         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Logs_Action_Types_ID_seq" OWNED BY public."Logs_Action_Types"."ID";
          public          postgres    false    237         �            1259    34094    Logs_ID_seq    SEQUENCE     v   CREATE SEQUENCE public."Logs_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public."Logs_ID_seq";
       public          postgres    false    235         �           0    0    Logs_ID_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public."Logs_ID_seq" OWNED BY public."Logs"."ID";
          public          postgres    false    238         �            1259    34095    Payments    TABLE     �   CREATE TABLE public."Payments" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Sum" money,
    "Payment_Timestamp" timestamp with time zone
);
    DROP TABLE public."Payments";
       public         heap    postgres    false         �            1259    34098    Payments_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Payments_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Payments_ID_seq";
       public          postgres    false    239         �           0    0    Payments_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Payments_ID_seq" OWNED BY public."Payments"."ID";
          public          postgres    false    240         �            1259    34099    Repair_Works    TABLE     �   CREATE TABLE public."Repair_Works" (
    "ID" bigint NOT NULL,
    "ID_Room" bigint,
    "Description" text,
    "Start_Date" date,
    "End_Date" date
);
 "   DROP TABLE public."Repair_Works";
       public         heap    postgres    false         �            1259    34104    Repair_Works_ID_seq    SEQUENCE     ~   CREATE SEQUENCE public."Repair_Works_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."Repair_Works_ID_seq";
       public          postgres    false    241         �           0    0    Repair_Works_ID_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public."Repair_Works_ID_seq" OWNED BY public."Repair_Works"."ID";
          public          postgres    false    242         �            1259    34105    Rooms    TABLE     �   CREATE TABLE public."Rooms" (
    "ID" bigint NOT NULL,
    "Room_Number" bigint,
    "Floor" integer,
    "Number_Of_Seats" integer,
    "ID_Dormitory" bigint
);
    DROP TABLE public."Rooms";
       public         heap    postgres    false         �            1259    34108    Rooms_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Rooms_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Rooms_ID_seq";
       public          postgres    false    243         �           0    0    Rooms_ID_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public."Rooms_ID_seq" OWNED BY public."Rooms"."ID";
          public          postgres    false    244         �            1259    34109    Specialties    TABLE     x   CREATE TABLE public."Specialties" (
    "ID_Spec" bigint NOT NULL,
    "Name" character varying(50),
    "Desc" text
);
 !   DROP TABLE public."Specialties";
       public         heap    postgres    false         �            1259    34114    Specialties_ID_Spec_seq    SEQUENCE     �   CREATE SEQUENCE public."Specialties_ID_Spec_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Specialties_ID_Spec_seq";
       public          postgres    false    245         �           0    0    Specialties_ID_Spec_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Specialties_ID_Spec_seq" OWNED BY public."Specialties"."ID_Spec";
          public          postgres    false    246         �            1259    34115    Staffs    TABLE     P  CREATE TABLE public."Staffs" (
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
       public         heap    postgres    false         �            1259    34118    Staff_ID_seq    SEQUENCE     w   CREATE SEQUENCE public."Staff_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public."Staff_ID_seq";
       public          postgres    false    247         �           0    0    Staff_ID_seq    SEQUENCE OWNED BY     D   ALTER SEQUENCE public."Staff_ID_seq" OWNED BY public."Staffs"."ID";
          public          postgres    false    248         �            1259    34119    Students    TABLE     l  CREATE TABLE public."Students" (
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
       public         heap    postgres    false         �            1259    34122    Students_ID_seq    SEQUENCE     z   CREATE SEQUENCE public."Students_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."Students_ID_seq";
       public          postgres    false    249         �           0    0    Students_ID_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public."Students_ID_seq" OWNED BY public."Students"."ID";
          public          postgres    false    250         �            1259    34123    Universities    TABLE     �   CREATE TABLE public."Universities" (
    "ID_Uni" bigint NOT NULL,
    "Name" character varying(50),
    "Address" character varying(255),
    "Contact_Number" character varying(20)
);
 "   DROP TABLE public."Universities";
       public         heap    postgres    false         �            1259    34126    Universities_ID_Uni_seq    SEQUENCE     �   CREATE SEQUENCE public."Universities_ID_Uni_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Universities_ID_Uni_seq";
       public          postgres    false    251         �           0    0    Universities_ID_Uni_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Universities_ID_Uni_seq" OWNED BY public."Universities"."ID_Uni";
          public          postgres    false    252         �            1259    34127    Visits    TABLE     �   CREATE TABLE public."Visits" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Date_Time_Entered" timestamp with time zone,
    "Date_Time_Leaved" timestamp with time zone
);
    DROP TABLE public."Visits";
       public         heap    postgres    false         �            1259    34130    Visits_ID_seq    SEQUENCE     x   CREATE SEQUENCE public."Visits_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."Visits_ID_seq";
       public          postgres    false    253         �           0    0    Visits_ID_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."Visits_ID_seq" OWNED BY public."Visits"."ID";
          public          postgres    false    254         �            1259    34131    check_ins_details    VIEW     �  CREATE VIEW public.check_ins_details AS
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
       public          postgres    false    227    243    243    221    221    221    221    227    221    249    249    249    249    243                     1259    34136 "   complaints_and_suggestions_details    VIEW     �  CREATE VIEW public.complaints_and_suggestions_details AS
 SELECT cas."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    cas."Description",
    cas."Date_Of_Submission",
    cass."Name" AS "Status_Name"
   FROM ((public."Complaints_And_Suggestions" cas
     JOIN public."Complaints_And_Suggestions_Status" cass ON ((cas."ID_Status" = cass."ID")))
     JOIN public."Students" s ON ((cas."ID_Stud" = s."ID")));
 5   DROP VIEW public.complaints_and_suggestions_details;
       public          postgres    false    223    223    223    223    223    225    225    249    249    249    249                    1259    34141    furniture_and_equip_details    VIEW     �  CREATE VIEW public.furniture_and_equip_details AS
 SELECT fae."ID",
    fae."Name",
    faes."Name" AS "Status_Name",
    r."Room_Number",
    d."Name" AS "Dormitory_Name"
   FROM (((public."Furniture_And_Equipment" fae
     JOIN public."Furniture_And_Equipment_Status" faes ON ((fae."ID_Status" = faes."ID")))
     JOIN public."Rooms" r ON ((fae."ID_Room" = r."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
 .   DROP VIEW public.furniture_and_equip_details;
       public          postgres    false    231    229    227    231    243    243    243    229    229    229    227                    1259    34145    logs_details    VIEW     D  CREATE VIEW public.logs_details AS
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
       public          postgres    false    235    236    236    247    247    247    247    235    235    235                    1259    34149    payments_details    VIEW     �   CREATE VIEW public.payments_details AS
 SELECT pay."ID",
    pay."Sum",
    pay."Payment_Timestamp",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Payments" pay
     JOIN public."Students" s ON ((pay."ID_Stud" = s."ID")));
 #   DROP VIEW public.payments_details;
       public          postgres    false    249    249    249    239    239    239    239    249                    1259    34153    repair_works_details    VIEW     N  CREATE VIEW public.repair_works_details AS
 SELECT rw."ID",
    r."Room_Number",
    d."Name" AS "Dormitory_Name",
    rw."Description",
    rw."Start_Date",
    rw."End_Date"
   FROM ((public."Repair_Works" rw
     JOIN public."Rooms" r ON ((rw."ID_Room" = r."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
 '   DROP VIEW public.repair_works_details;
       public          postgres    false    227    243    243    243    241    241    241    241    241    227                    1259    34157    rooms_details    VIEW     �   CREATE VIEW public.rooms_details AS
 SELECT r."ID",
    r."Room_Number",
    r."Floor",
    r."Number_Of_Seats",
    d."Name" AS "Dormitory_Name"
   FROM (public."Rooms" r
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));
     DROP VIEW public.rooms_details;
       public          postgres    false    243    243    243    243    243    227    227                    1259    34161    staffs_details    VIEW     Q  CREATE VIEW public.staffs_details AS
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
       public          postgres    false    247    247    247    247    247    233    233    227    227    247    247                    1259    34165    student_details    VIEW       CREATE VIEW public.student_details AS
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
       public          postgres    false    249    245    245    249    249    249    249    249    251    251    249    249    249    227    227    249    249                    1259    34170    visits_details    VIEW     �   CREATE VIEW public.visits_details AS
 SELECT v."ID",
    v."Date_Time_Entered",
    v."Date_Time_Leaved",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Visits" v
     JOIN public."Students" s ON ((v."ID_Stud" = s."ID")));
 !   DROP VIEW public.visits_details;
       public          postgres    false    249    249    249    253    249    253    253    253         �           2604    34174    Check_Ins ID    DEFAULT     q   ALTER TABLE ONLY public."Check_Ins" ALTER COLUMN "ID" SET DEFAULT nextval('public."Check_In_ID_seq"'::regclass);
 ?   ALTER TABLE public."Check_Ins" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    222    221         �           2604    34175    Complaints_And_Suggestions ID    DEFAULT     �   ALTER TABLE ONLY public."Complaints_And_Suggestions" ALTER COLUMN "ID" SET DEFAULT nextval('public."Complaints_And_Suggestions_ID_seq"'::regclass);
 P   ALTER TABLE public."Complaints_And_Suggestions" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    224    223         �           2604    34176 $   Complaints_And_Suggestions_Status ID    DEFAULT     �   ALTER TABLE ONLY public."Complaints_And_Suggestions_Status" ALTER COLUMN "ID" SET DEFAULT nextval('public."Complaints_And_Suggestions_Status_ID_seq"'::regclass);
 W   ALTER TABLE public."Complaints_And_Suggestions_Status" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    226    225         �           2604    34177    Dormitory ID    DEFAULT     r   ALTER TABLE ONLY public."Dormitory" ALTER COLUMN "ID" SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);
 ?   ALTER TABLE public."Dormitory" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    228    227         �           2604    34178    Furniture_And_Equipment ID    DEFAULT     �   ALTER TABLE ONLY public."Furniture_And_Equipment" ALTER COLUMN "ID" SET DEFAULT nextval('public."Furniture_And_Equipment_ID_seq"'::regclass);
 M   ALTER TABLE public."Furniture_And_Equipment" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    230    229         �           2604    34179 !   Furniture_And_Equipment_Status ID    DEFAULT     �   ALTER TABLE ONLY public."Furniture_And_Equipment_Status" ALTER COLUMN "ID" SET DEFAULT nextval('public."Furniture_And_Equipment_Status_ID_seq"'::regclass);
 T   ALTER TABLE public."Furniture_And_Equipment_Status" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    232    231         �           2604    34180    Jobs ID    DEFAULT     g   ALTER TABLE ONLY public."Jobs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Job_ID_seq"'::regclass);
 :   ALTER TABLE public."Jobs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    234    233         �           2604    34181    Logs ID    DEFAULT     h   ALTER TABLE ONLY public."Logs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_ID_seq"'::regclass);
 :   ALTER TABLE public."Logs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    238    235         �           2604    34182    Logs_Action_Types ID    DEFAULT     �   ALTER TABLE ONLY public."Logs_Action_Types" ALTER COLUMN "ID" SET DEFAULT nextval('public."Logs_Action_Types_ID_seq"'::regclass);
 G   ALTER TABLE public."Logs_Action_Types" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    237    236         �           2604    34183    Payments ID    DEFAULT     p   ALTER TABLE ONLY public."Payments" ALTER COLUMN "ID" SET DEFAULT nextval('public."Payments_ID_seq"'::regclass);
 >   ALTER TABLE public."Payments" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    240    239         �           2604    34184    Repair_Works ID    DEFAULT     x   ALTER TABLE ONLY public."Repair_Works" ALTER COLUMN "ID" SET DEFAULT nextval('public."Repair_Works_ID_seq"'::regclass);
 B   ALTER TABLE public."Repair_Works" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    242    241         �           2604    34185    Rooms ID    DEFAULT     j   ALTER TABLE ONLY public."Rooms" ALTER COLUMN "ID" SET DEFAULT nextval('public."Rooms_ID_seq"'::regclass);
 ;   ALTER TABLE public."Rooms" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    244    243         �           2604    34186    Specialties ID_Spec    DEFAULT     �   ALTER TABLE ONLY public."Specialties" ALTER COLUMN "ID_Spec" SET DEFAULT nextval('public."Specialties_ID_Spec_seq"'::regclass);
 F   ALTER TABLE public."Specialties" ALTER COLUMN "ID_Spec" DROP DEFAULT;
       public          postgres    false    246    245         �           2604    34187 	   Staffs ID    DEFAULT     k   ALTER TABLE ONLY public."Staffs" ALTER COLUMN "ID" SET DEFAULT nextval('public."Staff_ID_seq"'::regclass);
 <   ALTER TABLE public."Staffs" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    248    247         �           2604    34188    Students ID    DEFAULT     p   ALTER TABLE ONLY public."Students" ALTER COLUMN "ID" SET DEFAULT nextval('public."Students_ID_seq"'::regclass);
 >   ALTER TABLE public."Students" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    250    249         �           2604    34189    Universities ID_Uni    DEFAULT     �   ALTER TABLE ONLY public."Universities" ALTER COLUMN "ID_Uni" SET DEFAULT nextval('public."Universities_ID_Uni_seq"'::regclass);
 F   ALTER TABLE public."Universities" ALTER COLUMN "ID_Uni" DROP DEFAULT;
       public          postgres    false    252    251         �           2604    34190 	   Visits ID    DEFAULT     l   ALTER TABLE ONLY public."Visits" ALTER COLUMN "ID" SET DEFAULT nextval('public."Visits_ID_seq"'::regclass);
 <   ALTER TABLE public."Visits" ALTER COLUMN "ID" DROP DEFAULT;
       public          postgres    false    254    253         �          0    34047 	   Check_Ins 
   TABLE DATA           n   COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM stdin;
    public          postgres    false    221       5033.dat �          0    34051    Complaints_And_Suggestions 
   TABLE DATA           y   COPY public."Complaints_And_Suggestions" ("ID", "ID_Stud", "Description", "Date_Of_Submission", "ID_Status") FROM stdin;
    public          postgres    false    223       5035.dat �          0    34057 !   Complaints_And_Suggestions_Status 
   TABLE DATA           Z   COPY public."Complaints_And_Suggestions_Status" ("ID", "Name", "Description") FROM stdin;
    public          postgres    false    225       5037.dat �          0    34063 	   Dormitory 
   TABLE DATA           P   COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    227       5039.dat �          0    34067    Furniture_And_Equipment 
   TABLE DATA           Y   COPY public."Furniture_And_Equipment" ("ID", "Name", "ID_Room", "ID_Status") FROM stdin;
    public          postgres    false    229       5041.dat �          0    34071    Furniture_And_Equipment_Status 
   TABLE DATA           W   COPY public."Furniture_And_Equipment_Status" ("ID", "Name", "Description") FROM stdin;
    public          postgres    false    231       5043.dat �          0    34077    Jobs 
   TABLE DATA           H   COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM stdin;
    public          postgres    false    233       5045.dat �          0    34083    Logs 
   TABLE DATA           n   COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM stdin;
    public          postgres    false    235       5047.dat �          0    34088    Logs_Action_Types 
   TABLE DATA           J   COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM stdin;
    public          postgres    false    236       5048.dat �          0    34095    Payments 
   TABLE DATA           Q   COPY public."Payments" ("ID", "ID_Stud", "Sum", "Payment_Timestamp") FROM stdin;
    public          postgres    false    239       5051.dat �          0    34099    Repair_Works 
   TABLE DATA           b   COPY public."Repair_Works" ("ID", "ID_Room", "Description", "Start_Date", "End_Date") FROM stdin;
    public          postgres    false    241       5053.dat �          0    34105    Rooms 
   TABLE DATA           b   COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM stdin;
    public          postgres    false    243       5055.dat �          0    34109    Specialties 
   TABLE DATA           B   COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM stdin;
    public          postgres    false    245       5057.dat �          0    34115    Staffs 
   TABLE DATA           �   COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM stdin;
    public          postgres    false    247       5059.dat �          0    34119    Students 
   TABLE DATA           �   COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM stdin;
    public          postgres    false    249       5061.dat �          0    34123    Universities 
   TABLE DATA           W   COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM stdin;
    public          postgres    false    251       5063.dat �          0    34127    Visits 
   TABLE DATA           \   COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM stdin;
    public          postgres    false    253       5065.dat �           0    0    Check_In_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);
          public          postgres    false    222         �           0    0 !   Complaints_And_Suggestions_ID_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public."Complaints_And_Suggestions_ID_seq"', 1, false);
          public          postgres    false    224         �           0    0 (   Complaints_And_Suggestions_Status_ID_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public."Complaints_And_Suggestions_Status_ID_seq"', 1, false);
          public          postgres    false    226         �           0    0    Dormitory_ID_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, false);
          public          postgres    false    228         �           0    0    Furniture_And_Equipment_ID_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public."Furniture_And_Equipment_ID_seq"', 1, false);
          public          postgres    false    230         �           0    0 %   Furniture_And_Equipment_Status_ID_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public."Furniture_And_Equipment_Status_ID_seq"', 1, false);
          public          postgres    false    232         �           0    0 
   Job_ID_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public."Job_ID_seq"', 1, false);
          public          postgres    false    234         �           0    0    Logs_Action_Types_ID_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Logs_Action_Types_ID_seq"', 3, true);
          public          postgres    false    237         �           0    0    Logs_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Logs_ID_seq"', 1, false);
          public          postgres    false    238         �           0    0    Payments_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Payments_ID_seq"', 1, false);
          public          postgres    false    240         �           0    0    Repair_Works_ID_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public."Repair_Works_ID_seq"', 1, false);
          public          postgres    false    242         �           0    0    Rooms_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);
          public          postgres    false    244         �           0    0    Specialties_ID_Spec_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 1, false);
          public          postgres    false    246         �           0    0    Staff_ID_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public."Staff_ID_seq"', 1, false);
          public          postgres    false    248         �           0    0    Students_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Students_ID_seq"', 1, false);
          public          postgres    false    250         �           0    0    Universities_ID_Uni_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Universities_ID_Uni_seq"', 1, false);
          public          postgres    false    252         �           0    0    Visits_ID_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."Visits_ID_seq"', 1, false);
          public          postgres    false    254         �           2606    34192    Check_Ins Check_Ins_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "Check_Ins_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "Check_Ins_pkey";
       public            postgres    false    221         �           2606    34194 H   Complaints_And_Suggestions_Status Complaints_And_Suggestions_Status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Complaints_And_Suggestions_Status"
    ADD CONSTRAINT "Complaints_And_Suggestions_Status_pkey" PRIMARY KEY ("ID");
 v   ALTER TABLE ONLY public."Complaints_And_Suggestions_Status" DROP CONSTRAINT "Complaints_And_Suggestions_Status_pkey";
       public            postgres    false    225         �           2606    34196 :   Complaints_And_Suggestions Complaints_And_Suggestions_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "Complaints_And_Suggestions_pkey" PRIMARY KEY ("ID");
 h   ALTER TABLE ONLY public."Complaints_And_Suggestions" DROP CONSTRAINT "Complaints_And_Suggestions_pkey";
       public            postgres    false    223         �           2606    34198    Dormitory Dormitory_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."Dormitory"
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY ("ID");
 F   ALTER TABLE ONLY public."Dormitory" DROP CONSTRAINT "Dormitory_pkey";
       public            postgres    false    227         �           2606    34200 B   Furniture_And_Equipment_Status Furniture_And_Equipment_Status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Furniture_And_Equipment_Status"
    ADD CONSTRAINT "Furniture_And_Equipment_Status_pkey" PRIMARY KEY ("ID");
 p   ALTER TABLE ONLY public."Furniture_And_Equipment_Status" DROP CONSTRAINT "Furniture_And_Equipment_Status_pkey";
       public            postgres    false    231         �           2606    34202 4   Furniture_And_Equipment Furniture_And_Equipment_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "Furniture_And_Equipment_pkey" PRIMARY KEY ("ID");
 b   ALTER TABLE ONLY public."Furniture_And_Equipment" DROP CONSTRAINT "Furniture_And_Equipment_pkey";
       public            postgres    false    229         �           2606    34204    Jobs Job_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public."Jobs"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("ID");
 ;   ALTER TABLE ONLY public."Jobs" DROP CONSTRAINT "Job_pkey";
       public            postgres    false    233         �           2606    34206 (   Logs_Action_Types Logs_Action_Types_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Logs_Action_Types"
    ADD CONSTRAINT "Logs_Action_Types_pkey" PRIMARY KEY ("ID");
 V   ALTER TABLE ONLY public."Logs_Action_Types" DROP CONSTRAINT "Logs_Action_Types_pkey";
       public            postgres    false    236         �           2606    34208    Logs Logs_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY ("ID");
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "Logs_pkey";
       public            postgres    false    235         �           2606    34210    Payments Payments_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "Payments_pkey" PRIMARY KEY ("ID");
 D   ALTER TABLE ONLY public."Payments" DROP CONSTRAINT "Payments_pkey";
       public            postgres    false    239         �           2606    34212    Repair_Works Repair_Works_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public."Repair_Works"
    ADD CONSTRAINT "Repair_Works_pkey" PRIMARY KEY ("ID");
 L   ALTER TABLE ONLY public."Repair_Works" DROP CONSTRAINT "Repair_Works_pkey";
       public            postgres    false    241         �           2606    34214    Rooms Rooms_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "Rooms_pkey" PRIMARY KEY ("ID");
 >   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "Rooms_pkey";
       public            postgres    false    243         �           2606    34216    Specialties Specialties_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Specialties"
    ADD CONSTRAINT "Specialties_pkey" PRIMARY KEY ("ID_Spec");
 J   ALTER TABLE ONLY public."Specialties" DROP CONSTRAINT "Specialties_pkey";
       public            postgres    false    245         �           2606    34218    Staffs Staff_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "Staff_pkey" PRIMARY KEY ("ID");
 ?   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "Staff_pkey";
       public            postgres    false    247         �           2606    34220    Students Students_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "Students_pkey" PRIMARY KEY ("ID");
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "Students_pkey";
       public            postgres    false    249         �           2606    34222    Universities Universities_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public."Universities"
    ADD CONSTRAINT "Universities_pkey" PRIMARY KEY ("ID_Uni");
 L   ALTER TABLE ONLY public."Universities" DROP CONSTRAINT "Universities_pkey";
       public            postgres    false    251         �           2606    34224    Visits Visits_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "Visits_pkey" PRIMARY KEY ("ID");
 @   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "Visits_pkey";
       public            postgres    false    253                    2620    34312 "   Staffs before_insert_hash_password    TRIGGER     �   CREATE TRIGGER before_insert_hash_password BEFORE INSERT ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password();
 =   DROP TRIGGER before_insert_hash_password ON public."Staffs";
       public          postgres    false    247    301                    2620    34314 "   Staffs before_update_hash_password    TRIGGER     �   CREATE TRIGGER before_update_hash_password BEFORE UPDATE ON public."Staffs" FOR EACH ROW EXECUTE FUNCTION public.hash_password_update();
 =   DROP TRIGGER before_update_hash_password ON public."Staffs";
       public          postgres    false    247    302                    2606    34225    Logs FK_Action    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Action" FOREIGN KEY ("ID_Action_Type") REFERENCES public."Logs_Action_Types"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Action";
       public          postgres    false    235    236    4844         
           2606    34230    Students FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    227    249    4834                    2606    34235    Staffs FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 A   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    247    227    4834                    2606    34240    Rooms FK_Dormitory    FK CONSTRAINT     �   ALTER TABLE ONLY public."Rooms"
    ADD CONSTRAINT "FK_Dormitory" FOREIGN KEY ("ID_Dormitory") REFERENCES public."Dormitory"("ID") NOT VALID;
 @   ALTER TABLE ONLY public."Rooms" DROP CONSTRAINT "FK_Dormitory";
       public          postgres    false    4834    243    227         	           2606    34245    Staffs FK_Jobs    FK CONSTRAINT        ALTER TABLE ONLY public."Staffs"
    ADD CONSTRAINT "FK_Jobs" FOREIGN KEY ("ID_Job") REFERENCES public."Jobs"("ID") NOT VALID;
 <   ALTER TABLE ONLY public."Staffs" DROP CONSTRAINT "FK_Jobs";
       public          postgres    false    4840    247    233                    2606    34250    Furniture_And_Equipment FK_Room    FK CONSTRAINT     �   ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;
 M   ALTER TABLE ONLY public."Furniture_And_Equipment" DROP CONSTRAINT "FK_Room";
       public          postgres    false    243    4850    229         �           2606    34255    Check_Ins FK_Room    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Room";
       public          postgres    false    221    4850    243                    2606    34260    Repair_Works FK_Rooms    FK CONSTRAINT     �   ALTER TABLE ONLY public."Repair_Works"
    ADD CONSTRAINT "FK_Rooms" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Repair_Works" DROP CONSTRAINT "FK_Rooms";
       public          postgres    false    4850    243    241                    2606    34265    Students FK_Specialites    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_Specialites" FOREIGN KEY ("ID_Speci") REFERENCES public."Specialties"("ID_Spec") NOT VALID;
 E   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_Specialites";
       public          postgres    false    245    249    4852                    2606    34270    Logs FK_Staff    FK CONSTRAINT     �   ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "FK_Staff" FOREIGN KEY ("ID_Staff") REFERENCES public."Staffs"("ID") NOT VALID;
 ;   ALTER TABLE ONLY public."Logs" DROP CONSTRAINT "FK_Staff";
       public          postgres    false    235    247    4854                    2606    34275 !   Furniture_And_Equipment FK_Status    FK CONSTRAINT     �   ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "FK_Status" FOREIGN KEY ("ID_Status") REFERENCES public."Furniture_And_Equipment_Status"("ID") NOT VALID;
 O   ALTER TABLE ONLY public."Furniture_And_Equipment" DROP CONSTRAINT "FK_Status";
       public          postgres    false    4838    231    229         �           2606    34280 $   Complaints_And_Suggestions FK_Status    FK CONSTRAINT     �   ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "FK_Status" FOREIGN KEY ("ID_Status") REFERENCES public."Complaints_And_Suggestions_Status"("ID") NOT VALID;
 R   ALTER TABLE ONLY public."Complaints_And_Suggestions" DROP CONSTRAINT "FK_Status";
       public          postgres    false    4832    225    223                    2606    34285    Visits FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 ?   ALTER TABLE ONLY public."Visits" DROP CONSTRAINT "FK_Student";
       public          postgres    false    253    249    4856                     2606    34290 %   Complaints_And_Suggestions FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 S   ALTER TABLE ONLY public."Complaints_And_Suggestions" DROP CONSTRAINT "FK_Student";
       public          postgres    false    249    4856    223         �           2606    34295    Check_Ins FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 B   ALTER TABLE ONLY public."Check_Ins" DROP CONSTRAINT "FK_Student";
       public          postgres    false    221    249    4856                    2606    34300    Payments FK_Student    FK CONSTRAINT     �   ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;
 A   ALTER TABLE ONLY public."Payments" DROP CONSTRAINT "FK_Student";
       public          postgres    false    249    239    4856                    2606    34305    Students FK_University    FK CONSTRAINT     �   ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_University" FOREIGN KEY ("ID_Uni") REFERENCES public."Universities"("ID_Uni") NOT VALID;
 D   ALTER TABLE ONLY public."Students" DROP CONSTRAINT "FK_University";
       public          postgres    false    251    4858    249                                       5033.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014244 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5035.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014246 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5037.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014250 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5039.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014252 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5041.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014243 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5043.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014245 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5045.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014247 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5047.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014251 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5048.dat                                                                                            0000600 0004000 0002000 00000000525 14671431351 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Изменения в таблице	Информация о изменениях в таблице
2	Добавление в таблице	Информация о добавленой записе в таблице
3	Удаление из таблицы	Инфомрация об удаленных данных из таблицы
\.


                                                                                                                                                                           5051.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014244 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5053.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014246 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5055.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014250 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5057.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014252 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5059.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5061.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014245 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5063.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014247 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           5065.dat                                                                                            0000600 0004000 0002000 00000000005 14671431351 0014251 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000140543 14671431351 0015400 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
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


ALTER FUNCTION public.compare_jsons(json1 json, json2 json, table_name text, key_column text) OWNER TO postgres;

--
-- Name: delete_from_table(text, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    delete_query TEXT;
BEGIN
    delete_query := 'DELETE FROM ' || delete_table_name || ' WHERE ' || id_column || ' = ' || id_value;
    EXECUTE delete_query;
END;
$$;


ALTER PROCEDURE public.delete_from_table(IN delete_table_name text, IN id_column text, IN id_value integer) OWNER TO postgres;

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
    NEW.Password := MD5(NEW.Password);
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
    IF NEW.Password IS DISTINCT FROM OLD.Password THEN
        NEW.Password := MD5(NEW.Password);
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
-- Name: insert_into_table(text, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_into_table(IN insert_table_name text, IN insert_columns json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    "column_name" Text;
	"column_value" text;
	column_names TEXT;
    column_values TEXT;
    insert_query TEXT;
BEGIN
    column_names := '';
    column_values := '';

    FOR "column_name", "column_value" IN
        SELECT "key", "value"
        FROM json_each_text(insert_columns)
    LOOP
        column_names := column_names || "column_name" || ', ';
        column_values := column_values || quote_literal(column_value) || ', ';
    END LOOP;

    -- Удаляем последнюю запятую и пробел
    column_names := left(column_names, length(column_names) - 2);
    column_values := left(column_values, length(column_values) - 2);

    insert_query := 'INSERT INTO ' || insert_table_name || ' (' || column_names || ') VALUES (' || column_values || ')';
    EXECUTE insert_query;
END;
$$;


ALTER PROCEDURE public.insert_into_table(IN insert_table_name text, IN insert_columns json) OWNER TO postgres;

--
-- Name: update_table(text, text, integer, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value integer, IN update_columns json)
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


ALTER PROCEDURE public.update_table(IN update_table_name text, IN id_column text, IN id_value integer, IN update_columns json) OWNER TO postgres;

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
-- Name: Complaints_And_Suggestions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Complaints_And_Suggestions" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Description" text,
    "Date_Of_Submission" timestamp with time zone,
    "ID_Status" bigint
);


ALTER TABLE public."Complaints_And_Suggestions" OWNER TO postgres;

--
-- Name: Complaints_And_Suggestions_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Complaints_And_Suggestions_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Complaints_And_Suggestions_ID_seq" OWNER TO postgres;

--
-- Name: Complaints_And_Suggestions_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Complaints_And_Suggestions_ID_seq" OWNED BY public."Complaints_And_Suggestions"."ID";


--
-- Name: Complaints_And_Suggestions_Status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Complaints_And_Suggestions_Status" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);


ALTER TABLE public."Complaints_And_Suggestions_Status" OWNER TO postgres;

--
-- Name: Complaints_And_Suggestions_Status_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq" OWNER TO postgres;

--
-- Name: Complaints_And_Suggestions_Status_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Complaints_And_Suggestions_Status_ID_seq" OWNED BY public."Complaints_And_Suggestions_Status"."ID";


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
-- Name: Furniture_And_Equipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Furniture_And_Equipment" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "ID_Room" bigint,
    "ID_Status" bigint
);


ALTER TABLE public."Furniture_And_Equipment" OWNER TO postgres;

--
-- Name: Furniture_And_Equipment_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Furniture_And_Equipment_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Furniture_And_Equipment_ID_seq" OWNER TO postgres;

--
-- Name: Furniture_And_Equipment_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Furniture_And_Equipment_ID_seq" OWNED BY public."Furniture_And_Equipment"."ID";


--
-- Name: Furniture_And_Equipment_Status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Furniture_And_Equipment_Status" (
    "ID" bigint NOT NULL,
    "Name" character varying(50),
    "Description" text
);


ALTER TABLE public."Furniture_And_Equipment_Status" OWNER TO postgres;

--
-- Name: Furniture_And_Equipment_Status_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Furniture_And_Equipment_Status_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Furniture_And_Equipment_Status_ID_seq" OWNER TO postgres;

--
-- Name: Furniture_And_Equipment_Status_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Furniture_And_Equipment_Status_ID_seq" OWNED BY public."Furniture_And_Equipment_Status"."ID";


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
-- Name: Payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payments" (
    "ID" bigint NOT NULL,
    "ID_Stud" bigint,
    "Sum" money,
    "Payment_Timestamp" timestamp with time zone
);


ALTER TABLE public."Payments" OWNER TO postgres;

--
-- Name: Payments_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Payments_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Payments_ID_seq" OWNER TO postgres;

--
-- Name: Payments_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Payments_ID_seq" OWNED BY public."Payments"."ID";


--
-- Name: Repair_Works; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Repair_Works" (
    "ID" bigint NOT NULL,
    "ID_Room" bigint,
    "Description" text,
    "Start_Date" date,
    "End_Date" date
);


ALTER TABLE public."Repair_Works" OWNER TO postgres;

--
-- Name: Repair_Works_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Repair_Works_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Repair_Works_ID_seq" OWNER TO postgres;

--
-- Name: Repair_Works_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Repair_Works_ID_seq" OWNED BY public."Repair_Works"."ID";


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
-- Name: complaints_and_suggestions_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.complaints_and_suggestions_details AS
 SELECT cas."ID",
    s."Surname",
    s."Name",
    s."Patronymic",
    cas."Description",
    cas."Date_Of_Submission",
    cass."Name" AS "Status_Name"
   FROM ((public."Complaints_And_Suggestions" cas
     JOIN public."Complaints_And_Suggestions_Status" cass ON ((cas."ID_Status" = cass."ID")))
     JOIN public."Students" s ON ((cas."ID_Stud" = s."ID")));


ALTER VIEW public.complaints_and_suggestions_details OWNER TO postgres;

--
-- Name: furniture_and_equip_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.furniture_and_equip_details AS
 SELECT fae."ID",
    fae."Name",
    faes."Name" AS "Status_Name",
    r."Room_Number",
    d."Name" AS "Dormitory_Name"
   FROM (((public."Furniture_And_Equipment" fae
     JOIN public."Furniture_And_Equipment_Status" faes ON ((fae."ID_Status" = faes."ID")))
     JOIN public."Rooms" r ON ((fae."ID_Room" = r."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));


ALTER VIEW public.furniture_and_equip_details OWNER TO postgres;

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
-- Name: payments_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.payments_details AS
 SELECT pay."ID",
    pay."Sum",
    pay."Payment_Timestamp",
    s."Surname",
    s."Name",
    s."Patronymic"
   FROM (public."Payments" pay
     JOIN public."Students" s ON ((pay."ID_Stud" = s."ID")));


ALTER VIEW public.payments_details OWNER TO postgres;

--
-- Name: repair_works_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repair_works_details AS
 SELECT rw."ID",
    r."Room_Number",
    d."Name" AS "Dormitory_Name",
    rw."Description",
    rw."Start_Date",
    rw."End_Date"
   FROM ((public."Repair_Works" rw
     JOIN public."Rooms" r ON ((rw."ID_Room" = r."ID")))
     JOIN public."Dormitory" d ON ((r."ID_Dormitory" = d."ID")));


ALTER VIEW public.repair_works_details OWNER TO postgres;

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
-- Name: Complaints_And_Suggestions ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions" ALTER COLUMN "ID" SET DEFAULT nextval('public."Complaints_And_Suggestions_ID_seq"'::regclass);


--
-- Name: Complaints_And_Suggestions_Status ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions_Status" ALTER COLUMN "ID" SET DEFAULT nextval('public."Complaints_And_Suggestions_Status_ID_seq"'::regclass);


--
-- Name: Dormitory ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dormitory" ALTER COLUMN "ID" SET DEFAULT nextval('public."Dormitory_ID_seq"'::regclass);


--
-- Name: Furniture_And_Equipment ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment" ALTER COLUMN "ID" SET DEFAULT nextval('public."Furniture_And_Equipment_ID_seq"'::regclass);


--
-- Name: Furniture_And_Equipment_Status ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment_Status" ALTER COLUMN "ID" SET DEFAULT nextval('public."Furniture_And_Equipment_Status_ID_seq"'::regclass);


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
-- Name: Payments ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payments" ALTER COLUMN "ID" SET DEFAULT nextval('public."Payments_ID_seq"'::regclass);


--
-- Name: Repair_Works ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Repair_Works" ALTER COLUMN "ID" SET DEFAULT nextval('public."Repair_Works_ID_seq"'::regclass);


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
COPY public."Check_Ins" ("ID", "ID_Stud", "ID_Room", "Check_In_Timestamp", "Check_Out_Timestamp") FROM '$$PATH$$/5033.dat';

--
-- Data for Name: Complaints_And_Suggestions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Complaints_And_Suggestions" ("ID", "ID_Stud", "Description", "Date_Of_Submission", "ID_Status") FROM stdin;
\.
COPY public."Complaints_And_Suggestions" ("ID", "ID_Stud", "Description", "Date_Of_Submission", "ID_Status") FROM '$$PATH$$/5035.dat';

--
-- Data for Name: Complaints_And_Suggestions_Status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Complaints_And_Suggestions_Status" ("ID", "Name", "Description") FROM stdin;
\.
COPY public."Complaints_And_Suggestions_Status" ("ID", "Name", "Description") FROM '$$PATH$$/5037.dat';

--
-- Data for Name: Dormitory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM stdin;
\.
COPY public."Dormitory" ("ID", "Name", "Address", "Contact_Number") FROM '$$PATH$$/5039.dat';

--
-- Data for Name: Furniture_And_Equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Furniture_And_Equipment" ("ID", "Name", "ID_Room", "ID_Status") FROM stdin;
\.
COPY public."Furniture_And_Equipment" ("ID", "Name", "ID_Room", "ID_Status") FROM '$$PATH$$/5041.dat';

--
-- Data for Name: Furniture_And_Equipment_Status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Furniture_And_Equipment_Status" ("ID", "Name", "Description") FROM stdin;
\.
COPY public."Furniture_And_Equipment_Status" ("ID", "Name", "Description") FROM '$$PATH$$/5043.dat';

--
-- Data for Name: Jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM stdin;
\.
COPY public."Jobs" ("ID", "Name", "Acceses", "Description") FROM '$$PATH$$/5045.dat';

--
-- Data for Name: Logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM stdin;
\.
COPY public."Logs" ("ID", "Action_Timestamp", "ID_Action_Type", "ID_Staff", "Action_Description") FROM '$$PATH$$/5047.dat';

--
-- Data for Name: Logs_Action_Types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM stdin;
\.
COPY public."Logs_Action_Types" ("ID", "Name", "Description") FROM '$$PATH$$/5048.dat';

--
-- Data for Name: Payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Payments" ("ID", "ID_Stud", "Sum", "Payment_Timestamp") FROM stdin;
\.
COPY public."Payments" ("ID", "ID_Stud", "Sum", "Payment_Timestamp") FROM '$$PATH$$/5051.dat';

--
-- Data for Name: Repair_Works; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Repair_Works" ("ID", "ID_Room", "Description", "Start_Date", "End_Date") FROM stdin;
\.
COPY public."Repair_Works" ("ID", "ID_Room", "Description", "Start_Date", "End_Date") FROM '$$PATH$$/5053.dat';

--
-- Data for Name: Rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM stdin;
\.
COPY public."Rooms" ("ID", "Room_Number", "Floor", "Number_Of_Seats", "ID_Dormitory") FROM '$$PATH$$/5055.dat';

--
-- Data for Name: Specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM stdin;
\.
COPY public."Specialties" ("ID_Spec", "Name", "Desc") FROM '$$PATH$$/5057.dat';

--
-- Data for Name: Staffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM stdin;
\.
COPY public."Staffs" ("ID", "Surname", "Name", "Patronymic", "ID_Job", "Contact_Number", "ID_Dormitory", "Login", "Password") FROM '$$PATH$$/5059.dat';

--
-- Data for Name: Students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM stdin;
\.
COPY public."Students" ("ID", "Surname", "Name", "Patronymic", "Birth_Date", "Sex", "Contact_Number", "Email", "ID_Uni", "ID_Speci", "ID_Dormitory") FROM '$$PATH$$/5061.dat';

--
-- Data for Name: Universities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM stdin;
\.
COPY public."Universities" ("ID_Uni", "Name", "Address", "Contact_Number") FROM '$$PATH$$/5063.dat';

--
-- Data for Name: Visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM stdin;
\.
COPY public."Visits" ("ID", "ID_Stud", "Date_Time_Entered", "Date_Time_Leaved") FROM '$$PATH$$/5065.dat';

--
-- Name: Check_In_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Check_In_ID_seq"', 1, false);


--
-- Name: Complaints_And_Suggestions_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Complaints_And_Suggestions_ID_seq"', 1, false);


--
-- Name: Complaints_And_Suggestions_Status_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Complaints_And_Suggestions_Status_ID_seq"', 1, false);


--
-- Name: Dormitory_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Dormitory_ID_seq"', 1, false);


--
-- Name: Furniture_And_Equipment_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Furniture_And_Equipment_ID_seq"', 1, false);


--
-- Name: Furniture_And_Equipment_Status_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Furniture_And_Equipment_Status_ID_seq"', 1, false);


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

SELECT pg_catalog.setval('public."Logs_ID_seq"', 1, false);


--
-- Name: Payments_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Payments_ID_seq"', 1, false);


--
-- Name: Repair_Works_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Repair_Works_ID_seq"', 1, false);


--
-- Name: Rooms_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rooms_ID_seq"', 1, false);


--
-- Name: Specialties_ID_Spec_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Specialties_ID_Spec_seq"', 1, false);


--
-- Name: Staff_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Staff_ID_seq"', 1, false);


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
-- Name: Complaints_And_Suggestions_Status Complaints_And_Suggestions_Status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions_Status"
    ADD CONSTRAINT "Complaints_And_Suggestions_Status_pkey" PRIMARY KEY ("ID");


--
-- Name: Complaints_And_Suggestions Complaints_And_Suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "Complaints_And_Suggestions_pkey" PRIMARY KEY ("ID");


--
-- Name: Dormitory Dormitory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dormitory"
    ADD CONSTRAINT "Dormitory_pkey" PRIMARY KEY ("ID");


--
-- Name: Furniture_And_Equipment_Status Furniture_And_Equipment_Status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment_Status"
    ADD CONSTRAINT "Furniture_And_Equipment_Status_pkey" PRIMARY KEY ("ID");


--
-- Name: Furniture_And_Equipment Furniture_And_Equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "Furniture_And_Equipment_pkey" PRIMARY KEY ("ID");


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
-- Name: Payments Payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "Payments_pkey" PRIMARY KEY ("ID");


--
-- Name: Repair_Works Repair_Works_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Repair_Works"
    ADD CONSTRAINT "Repair_Works_pkey" PRIMARY KEY ("ID");


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
-- Name: Furniture_And_Equipment FK_Room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;


--
-- Name: Check_Ins FK_Room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Room" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;


--
-- Name: Repair_Works FK_Rooms; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Repair_Works"
    ADD CONSTRAINT "FK_Rooms" FOREIGN KEY ("ID_Room") REFERENCES public."Rooms"("ID") NOT VALID;


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
-- Name: Furniture_And_Equipment FK_Status; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Furniture_And_Equipment"
    ADD CONSTRAINT "FK_Status" FOREIGN KEY ("ID_Status") REFERENCES public."Furniture_And_Equipment_Status"("ID") NOT VALID;


--
-- Name: Complaints_And_Suggestions FK_Status; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "FK_Status" FOREIGN KEY ("ID_Status") REFERENCES public."Complaints_And_Suggestions_Status"("ID") NOT VALID;


--
-- Name: Visits FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Visits"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Complaints_And_Suggestions FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Complaints_And_Suggestions"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Check_Ins FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Check_Ins"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Payments FK_Student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "FK_Student" FOREIGN KEY ("ID_Stud") REFERENCES public."Students"("ID") NOT VALID;


--
-- Name: Students FK_University; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Students"
    ADD CONSTRAINT "FK_University" FOREIGN KEY ("ID_Uni") REFERENCES public."Universities"("ID_Uni") NOT VALID;


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
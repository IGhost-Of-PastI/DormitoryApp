drop function compare_jsons;

CREATE OR REPLACE FUNCTION compare_jsons(
    json1 json,
    json2 json,
    table_name text,
    key_column text
)
RETURNS json AS $$
DECLARE
    changes json;
    obj1 json;
    obj2 json;
    key_value text;
    change json;
    json_key text;
    keys text[];
BEGIN
    FOR obj1 IN SELECT * FROM json_array_elements(json1::json) LOOP
        key_value := obj1->>key_column;
        obj2 := (SELECT value FROM jsonb_array_elements(json2::json) value WHERE value->>key_column = key_value);
        
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_log_event(
    p_person_id INT,
    p_level VARCHAR,
    p_module VARCHAR,
    p_action VARCHAR,
    p_entity VARCHAR,
    p_entity_id INT,
    p_message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO AppLogs (
        personId, level, module, action, entity, entityId, message, createdAt
    )
    VALUES (
        p_person_id,
        p_level,
        p_module,
        p_action,
        p_entity,
        p_entity_id,
        p_message,
        CURRENT_TIMESTAMP
    );
END;
$$;
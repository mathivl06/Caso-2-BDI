DELIMITER $$

CREATE PROCEDURE sp_log_event (
    IN p_user_id INT,
    IN p_level_id INT,
    IN p_module VARCHAR(50),
    IN p_action VARCHAR(100),
    IN p_entity VARCHAR(50),
    IN p_entity_id INT,
    IN p_message TEXT
)
BEGIN
    INSERT INTO AppLogs (
        userId, levelId, module, action, entity, entityId, message, createdAt
    )
    VALUES (
        p_user_id, p_level_id, p_module, p_action, p_entity, p_entity_id, p_message, CURRENT_TIMESTAMP
    );
END$$

DELIMITER ;
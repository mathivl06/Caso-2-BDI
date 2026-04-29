CREATE OR REPLACE PROCEDURE sp_log_event(
    p_procedure_name VARCHAR,
    p_message VARCHAR,
    p_status_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Logs (procedureName, message, logDate, logStatusId)
    VALUES (p_procedure_name, p_message, NOW(), p_status_id);
END;
$$;
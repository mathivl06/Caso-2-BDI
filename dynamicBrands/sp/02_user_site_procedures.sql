DELIMITER $$

CREATE PROCEDURE sp_create_user (
    IN p_name VARCHAR(50),
    IN p_last1 VARCHAR(50),
    IN p_last2 VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_user_id INT;

    INSERT INTO Users(name, lastName1, lastName2, email, passwordHash, status)
    VALUES (p_name, p_last1, p_last2, p_email, p_password, p_status);

    SET v_user_id = LAST_INSERT_ID();

    CALL sp_log_event(v_user_id, 1, 'USER', 'CREATE', 'Users', v_user_id, 'User created');

END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_create_site (
    IN p_name VARCHAR(100),
    IN p_url VARCHAR(255),
    IN p_country_id INT,
    IN p_currency_id INT,
    IN p_created_by INT
)
BEGIN
    DECLARE v_site_id INT;

    INSERT INTO Sites (
        name, url, countryId, currencyId, isActive, validFrom, createdBy
    )
    VALUES (
        p_name, p_url, p_country_id, p_currency_id, TRUE, CURRENT_DATE, p_created_by
    );

    SET v_site_id = LAST_INSERT_ID();

    CALL sp_log_event(p_created_by, 1, 'SITE', 'CREATE', 'Sites', v_site_id, 'Site created');

END$$

DELIMITER ;
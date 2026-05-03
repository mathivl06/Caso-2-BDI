DELIMITER $$

CREATE PROCEDURE sp_seed_data()
BEGIN

    -- Usuario base
    CALL sp_create_user('Admin', 'System', '', 'admin@test.com', 'hash', 'ACTIVE');

    -- Sitio
    CALL sp_create_site('Site CR', 'cr.shop.com', 1, 1, 1);

    -- Producto conectado con Etheria
    CALL sp_create_product('EXT-001', 'Aceite Premium', 1, NULL, 10, 1, 1);

    -- Precio local
    CALL sp_set_product_price(1, 1, 15000, 1, NULL, 1);

    -- Orden
    CALL sp_create_order('ORD-001', 1, NULL, 1, 1, 1);

    CALL sp_add_order_item(1, 1, 2, 15000);

    CALL sp_log_event(1, 1, 'SYSTEM', 'SEED', 'SYSTEM', NULL, 'Dynamic seed executed');

END$$

DELIMITER ;
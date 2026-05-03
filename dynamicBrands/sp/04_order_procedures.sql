DELIMITER $$

CREATE PROCEDURE sp_create_order (
    IN p_order_number VARCHAR(50),
    IN p_site_id INT,
    IN p_customer_id INT,
    IN p_currency_id INT,
    IN p_status_id INT,
    IN p_user INT
)
BEGIN
    DECLARE v_order_id INT;

    INSERT INTO Orders (
        orderNumber, siteId, customerId, currencyId,
        statusId, createdBy
    )
    VALUES (
        p_order_number, p_site_id, p_customer_id,
        p_currency_id, p_status_id, p_user
    );

    SET v_order_id = LAST_INSERT_ID();

    CALL sp_log_event(p_user, 1, 'ORDER', 'CREATE', 'Orders', v_order_id, 'Order created');

END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_add_order_item (
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(14,2)
)
BEGIN
    INSERT INTO OrderItems (
        orderId, productId, quantity, unitPriceLocal
    )
    VALUES (
        p_order_id, p_product_id, p_quantity, p_price
    );
END$$

DELIMITER ;
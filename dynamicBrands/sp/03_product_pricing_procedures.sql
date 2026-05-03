DELIMITER $$

CREATE PROCEDURE sp_create_product (
    IN p_external_id VARCHAR(50),
    IN p_name VARCHAR(150),
    IN p_category INT,
    IN p_brand INT,
    IN p_cost DECIMAL(14,2),
    IN p_currency INT,
    IN p_user INT
)
BEGIN
    DECLARE v_product_id INT;

    INSERT INTO Products (
        externalProductId, productName, categoryId, brandId,
        baseCost, baseCurrencyId, createdBy
    )
    VALUES (
        p_external_id, p_name, p_category, p_brand,
        p_cost, p_currency, p_user
    );

    SET v_product_id = LAST_INSERT_ID();

    CALL sp_log_event(p_user, 1, 'PRODUCT', 'CREATE', 'Products', v_product_id, 'Product created');

END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_set_product_price (
    IN p_product_id INT,
    IN p_site_id INT,
    IN p_price DECIMAL(14,2),
    IN p_currency_id INT,
    IN p_exchange_id INT,
    IN p_user INT
)
BEGIN
    INSERT INTO ProductPrices (
        productId, siteId, priceLocal, currencyId, exchangeRateId,
        validFrom, createdBy
    )
    VALUES (
        p_product_id, p_site_id, p_price, p_currency_id, p_exchange_id,
        CURRENT_DATE, p_user
    );

    CALL sp_log_event(p_user, 1, 'PRICING', 'SET_PRICE', 'ProductPrices', p_product_id, 'Price assigned');

END$$

DELIMITER ;
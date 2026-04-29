CREATE OR REPLACE PROCEDURE sp_create_import_order(
    p_supplier_id INT,
    p_total_cost DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_import_id INT;
BEGIN
    INSERT INTO ImportOrders (supplierId, orderDate, totalCostUSD, importOrderStatusId)
    VALUES (p_supplier_id, NOW(), p_total_cost, 1)
    RETURNING importOrderId INTO v_import_id;

    CALL sp_log_event('sp_create_import_order', 'Import order created ID: ' || v_import_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_create_import_order', SQLERRM, 2);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_add_import_detail(
    p_import_id INT,
    p_product_id INT,
    p_quantity INT,
    p_unit_cost DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ImportOrderDetails (importOrderId, productId, quantity, unitCostUSD)
    VALUES (p_import_id, p_product_id, p_quantity, p_unit_cost);

    CALL sp_log_event('sp_add_import_detail', 'Detail added to import ' || p_import_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_add_import_detail', SQLERRM, 2);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_register_batch(
    p_product_id INT,
    p_import_id INT,
    p_quantity INT,
    p_unit_cost DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch_id INT;
BEGIN
    INSERT INTO Batches (productId, importOrderId, arrivalDate, quantityReceived, unitCostUSD)
    VALUES (p_product_id, p_import_id, NOW(), p_quantity, p_unit_cost)
    RETURNING batchId INTO v_batch_id;

    CALL sp_log_event('sp_register_batch', 'Batch created ID: ' || v_batch_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_register_batch', SQLERRM, 2);
END;
$$;
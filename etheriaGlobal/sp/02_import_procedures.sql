CREATE OR REPLACE PROCEDURE sp_create_import_order(
    p_import_number VARCHAR,
    p_supplier_id INT,
    p_currency_id INT,
    p_status_id INT,
    p_created_by INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_import_id INT;
BEGIN
    INSERT INTO ImportOrders (
        importOrderNumber,
        supplierId,
        orderDate,
        totalCost,
        currencyId,
        statusId,
        createdBy
    )
    VALUES (
        p_import_number,
        p_supplier_id,
        CURRENT_TIMESTAMP,
        0,
        p_currency_id,
        p_status_id,
        p_created_by
    )
    RETURNING importOrderId INTO v_import_id;

    CALL sp_log_event(p_created_by, 'INFO', 'IMPORT', 'CREATE_ORDER', 'ImportOrders', v_import_id,
                     'Import order created');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_created_by, 'ERROR', 'IMPORT', 'CREATE_ORDER', 'ImportOrders', NULL, SQLERRM);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_add_import_detail(
    p_import_id INT,
    p_product_id INT,
    p_quantity INT,
    p_unit_cost DECIMAL,
    p_currency_id INT,
    p_created_by INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_line_total DECIMAL;
BEGIN
    v_line_total := p_quantity * p_unit_cost;

    INSERT INTO ImportOrderDetails (
        importOrderId,
        productId,
        quantity,
        unitCost,
        currencyId,
        lineTotal
    )
    VALUES (
        p_import_id,
        p_product_id,
        p_quantity,
        p_unit_cost,
        p_currency_id,
        v_line_total
    );

    UPDATE ImportOrders
    SET totalCost = COALESCE(totalCost,0) + v_line_total
    WHERE importOrderId = p_import_id;

    CALL sp_log_event(p_created_by, 'INFO', 'IMPORT', 'ADD_DETAIL', 'ImportOrderDetails', p_import_id,
                     'Detail added');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_created_by, 'ERROR', 'IMPORT', 'ADD_DETAIL', 'ImportOrderDetails', p_import_id, SQLERRM);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_register_batch(
    p_batch_number VARCHAR,
    p_import_id INT,
    p_product_id INT,
    p_quantity DECIMAL,
    p_unit_cost DECIMAL,
    p_currency_id INT,
    p_received_by INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch_id INT;
BEGIN
    INSERT INTO Batches (
        batchNumber,
        importOrderId,
        productId,
        quantityReceived,
        unitCost,
        currencyId,
        receivedAt,
        receivedBy
    )
    VALUES (
        p_batch_number,
        p_import_id,
        p_product_id,
        p_quantity,
        p_unit_cost,
        p_currency_id,
        CURRENT_TIMESTAMP,
        p_received_by
    )
    RETURNING batchId INTO v_batch_id;

    CALL sp_log_event(p_received_by, 'INFO', 'IMPORT', 'REGISTER_BATCH', 'Batches', v_batch_id,
                     'Batch registered');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_received_by, 'ERROR', 'IMPORT', 'REGISTER_BATCH', 'Batches', NULL, SQLERRM);
END;
$$;
CREATE OR REPLACE PROCEDURE sp_inventory_movement(
    p_transaction_type INT,
    p_batch_id INT,
    p_warehouse_from INT,
    p_warehouse_to INT,
    p_quantity DECIMAL,
    p_product_id INT,
    p_unit_cost DECIMAL,
    p_currency_id INT,
    p_created_by INT,
    p_reference_type VARCHAR,
    p_reference_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_transaction_id BIGINT;
BEGIN
    INSERT INTO InventoryTransactionHeader (
        transactionTypeId,
        batchId,
        warehouseIdFrom,
        warehouseIdTo,
        transactionDate,
        referenceType,
        referenceId,
        createdBy
    )
    VALUES (
        p_transaction_type,
        p_batch_id,
        p_warehouse_from,
        p_warehouse_to,
        CURRENT_TIMESTAMP,
        p_reference_type,
        p_reference_id,
        p_created_by
    )
    RETURNING transactionId INTO v_transaction_id;

    INSERT INTO InventoryTransactionDetail (
        transactionId,
        productId,
        quantity,
        unitCost,
        currencyId
    )
    VALUES (
        v_transaction_id,
        p_product_id,
        p_quantity,
        p_unit_cost,
        p_currency_id
    );

    CALL sp_log_event(p_created_by, 'INFO', 'INVENTORY', 'MOVEMENT', 'InventoryTransaction', v_transaction_id,
                     'Inventory movement recorded');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_created_by, 'ERROR', 'INVENTORY', 'MOVEMENT', 'InventoryTransaction', NULL, SQLERRM);
END;
$$;
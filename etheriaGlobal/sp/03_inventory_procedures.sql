CREATE OR REPLACE PROCEDURE sp_add_inventory(
    p_batch_id INT,
    p_warehouse_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Inventory (batchId, warehouseId, quantity)
    VALUES (p_batch_id, p_warehouse_id, p_quantity);

    CALL sp_log_event('sp_add_inventory', 'Inventory added for batch ' || p_batch_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_add_inventory', SQLERRM, 2);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_inventory_transaction(
    p_batch_id INT,
    p_warehouse_id INT,
    p_quantity INT,
    p_type_id INT,
    p_reference_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO InventoryTransactions (
        batchId, warehouseId, quantity,
        inventoryTransactionTypeId, transactionDate, referenceId
    )
    VALUES (
        p_batch_id, p_warehouse_id, p_quantity,
        p_type_id, NOW(), p_reference_id
    );

    CALL sp_log_event('sp_inventory_transaction', 'Transaction recorded', 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_inventory_transaction', SQLERRM, 2);
END;
$$;
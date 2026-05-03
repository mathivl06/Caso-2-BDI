DELIMITER $$

CREATE PROCEDURE sp_register_inventory_reference (
    IN p_transaction_type INT,
    IN p_batch_id INT,
    IN p_reference_id INT,
    IN p_user INT
)
BEGIN
    DECLARE v_tx_id BIGINT;

    INSERT INTO InventoryTransactionHeader (
        transactionTypeId, batchId, referenceId, createdBy
    )
    VALUES (
        p_transaction_type, p_batch_id, p_reference_id, p_user
    );

    SET v_tx_id = LAST_INSERT_ID();

    CALL sp_log_event(p_user, 1, 'INVENTORY', 'REFERENCE', 'InventoryTransaction', v_tx_id,
                     'Inventory reference registered');

END$$

DELIMITER ;
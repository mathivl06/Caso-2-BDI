CREATE OR REPLACE PROCEDURE sp_create_dispatch(
    p_dispatch_number VARCHAR,
    p_country_id INT,
    p_status_id INT,
    p_created_by INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dispatch_id INT;
BEGIN
    INSERT INTO DispatchOrders (
        dispatchOrderNumber,
        destinationCountryId,
        dispatchDate,
        statusId,
        createdBy
    )
    VALUES (
        p_dispatch_number,
        p_country_id,
        CURRENT_TIMESTAMP,
        p_status_id,
        p_created_by
    )
    RETURNING dispatchOrderId INTO v_dispatch_id;

    CALL sp_log_event(p_created_by, 'INFO', 'DISPATCH', 'CREATE_ORDER', 'DispatchOrders', v_dispatch_id,
                     'Dispatch created');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_created_by, 'ERROR', 'DISPATCH', 'CREATE_ORDER', 'DispatchOrders', NULL, SQLERRM);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_add_dispatch_detail(
    p_dispatch_id INT,
    p_batch_id INT,
    p_quantity DECIMAL,
    p_created_by INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO DispatchOrderDetails (
        dispatchOrderId,
        batchId,
        quantityDispatched
    )
    VALUES (
        p_dispatch_id,
        p_batch_id,
        p_quantity
    );

    CALL sp_log_event(p_created_by, 'INFO', 'DISPATCH', 'ADD_DETAIL', 'DispatchOrderDetails', p_dispatch_id,
                     'Dispatch detail added');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(p_created_by, 'ERROR', 'DISPATCH', 'ADD_DETAIL', 'DispatchOrderDetails', p_dispatch_id, SQLERRM);
END;
$$;
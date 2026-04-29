CREATE OR REPLACE PROCEDURE sp_create_dispatch(
    p_country_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dispatch_id INT;
BEGIN
    INSERT INTO DispatchOrders (dispatchDate, destinationCountryId, dispatchStatusId)
    VALUES (NOW(), p_country_id, 1)
    RETURNING dispatchOrderId INTO v_dispatch_id;

    CALL sp_log_event('sp_create_dispatch', 'Dispatch created ID: ' || v_dispatch_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_create_dispatch', SQLERRM, 2);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_add_dispatch_detail(
    p_dispatch_id INT,
    p_batch_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO DispatchOrderDetails (dispatchOrderId, batchId, quantity)
    VALUES (p_dispatch_id, p_batch_id, p_quantity);

    CALL sp_log_event('sp_add_dispatch_detail', 'Dispatch detail added', 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_add_dispatch_detail', SQLERRM, 2);
END;
$$;
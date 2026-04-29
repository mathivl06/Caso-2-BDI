CREATE OR REPLACE PROCEDURE sp_seed_data() -- Aquí se llaman a los otros Stored Procedures, centraliza la carga de datos.
LANGUAGE plpgsql
AS $$
BEGIN
    -- Ejemplo simple (pueden expandirlo)

    CALL sp_create_import_order(1, 5000);
    CALL sp_add_import_detail(1, 1, 100, 10);
    CALL sp_register_batch(1, 1, 100, 10);
    CALL sp_add_inventory(1, 1, 100);

    CALL sp_create_dispatch(1);
    CALL sp_add_dispatch_detail(1, 1, 50);

    CALL sp_inventory_transaction(1, 1, -50, 2, 1);

    CALL sp_log_event('sp_seed_data', 'Seed executed successfully', 1);

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event('sp_seed_data', SQLERRM, 2);
END;
$$;
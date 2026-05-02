CREATE OR REPLACE PROCEDURE sp_seed_data()
LANGUAGE plpgsql
AS $$
BEGIN

    -- Version Basica.

    CALL sp_create_import_order('IMP-001', 1, 1, 1, 1);

    CALL sp_add_import_detail(1, 1, 100, 10, 1, 1);

    CALL sp_register_batch('BATCH-001', 1, 1, 100, 10, 1, 1);

    CALL sp_inventory_movement(
        1, -- tipo ENT
        1,
        1,
        NULL,
        100,
        1,
        10,
        1,
        1,
        'IMPORT',
        1
    );

    CALL sp_create_dispatch('DISP-001', 1, 1, 1);

    CALL sp_add_dispatch_detail(1, 1, 50, 1);

    CALL sp_inventory_movement(
        2, -- tipo SAL
        1,
        1,
        NULL,
        50,
        1,
        10,
        1,
        1,
        'DISPATCH',
        1
    );

    CALL sp_log_event(1, 'INFO', 'SYSTEM', 'SEED', 'SYSTEM', NULL, 'Seed executed');

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_log_event(1, 'ERROR', 'SYSTEM', 'SEED', 'SYSTEM', NULL, SQLERRM);
END;
$$;
-- Crear tablas
\i /scripts/Script_creacion_EtheriaDB_Postgres.sql

-- Stored Procedures
\i /scripts/01_log_procedure.sql
\i /scripts/02_import_procedures.sql
\i /scripts/03_inventory_procedures.sql
\i /scripts/04_dispatch_procedures.sql
\i /scripts/05_seed_orchestrator.sql

-- Ejecutar carga
CALL sp_seed_data();
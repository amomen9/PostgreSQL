-- Use the following when needed:
--SELECT pg_backend_pid();
--SELECT pg_rotate_logfile();


CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS my_log_server FOREIGN DATA WRAPPER file_fdw;



DROP FOREIGN TABLE IF EXISTS pg_log_file_dynamic;
CREATE FOREIGN TABLE pg_log_file_dynamic (
    log_time text,
    "user" text,
    "database" text,
    pid text,
    "Client Address:port" text,
    column6 text,
    process_log_id integer,
    "command_type/backend_status" text,
    column9 text,
    "timestamp(redundant)" text,
    column11 text,
    error_severity text,  -- Updated column name
    error_code text,
    system_message text,
    parameters_values text,
    suggestion text,
    error_fragment text,
    column18 text,
    "subject error and line number" text,
    "executed_text" text,
    column21 text,
    column22 text,
    application_name text,
    application_type text,
    column25 text,
    column26 text
)
SERVER my_log_server
OPTIONS (filename '', format 'csv');



CREATE OR REPLACE FUNCTION update_log_file_path()
RETURNS void AS $$
DECLARE
    logfile text;
BEGIN
    SELECT replace(pg_current_logfile(), '.log', '.csv') INTO logfile;
    EXECUTE 'ALTER FOREIGN TABLE pg_log_file_dynamic 
			OPTIONS (SET filename ''' || logfile || ''')';
END;
$$ LANGUAGE plpgsql;



-- Update the log file path
SELECT update_log_file_path();






-- Query the Foreign Table for Errors within a Specific Timestamp Period
SELECT log_time, "user", "database", pid, "Client Address:port", ('x' || split_part(column6, '.', 1))::bit(32)::int AS xid, ('x' || split_part(column6, '.', 2))::bit(16)::int AS "pid(redundant)", process_log_id, "command_type/backend_status", "timestamp(redundant)", column11, error_severity, error_code, system_message, parameters_values, suggestion, error_fragment, column18, "subject error and line number", executed_text, column21, column22, application_name, application_type, column25, column26
FROM pg_log_file_dynamic
ORDER BY log_time DESC


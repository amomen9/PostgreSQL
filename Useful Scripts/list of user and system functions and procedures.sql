-- =============================================
-- Author:              "a-momen"
-- Contact & Report:    "amomen@gmail.com"
-- Update date:         "2025-09-07"
-- Description:         "list of user and system functions and procedures"
-- License:             "Please refer to the license file"
-- =============================================



SELECT 
    p.proname AS function_name,
    n.nspname AS schema_name,
    pg_catalog.pg_get_function_result(p.oid) AS return_type,
    pg_catalog.pg_get_function_arguments(p.oid) AS argument_types,
    l.lanname AS language,
    p.prosrc AS source_code,
    p.protrftypes AS transformed_return_type_oids,
    CASE 
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'a' THEN 'Aggregate Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
        WHEN p.prokind = 'w' THEN 'Window Function'
        ELSE 'Unknown'
    END AS function_kind,
    p.probin AS binary_code,
    p.prosqlbody AS sql_body
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_language l ON p.prolang = l.oid
--where p.proname like '%func or proc%'		/* p.proname= function_name */
											/* p.prokind= function_type */
											/* n.nspname AS schema_name */											
ORDER BY n.nspname, p.proname;

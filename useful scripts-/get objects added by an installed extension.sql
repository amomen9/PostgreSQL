--create extension if not exists pageinspect;
--select * from pg_extension;


WITH pg_object AS (
    -- Objects from pg_class (Tables and Views)
    SELECT 
        c.oid AS objid,
        c.relname AS object_name,
        CASE 
            WHEN c.relkind = 'r' THEN 'Ordinary table'
            WHEN c.relkind = 'v' THEN 'View'
            ELSE 'Unknown'
        END AS object_type,
        string_agg(a.attname, ', ') AS columns -- Aggregates column names
    FROM pg_class c
    LEFT JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
    WHERE c.relkind IN ('r', 'v') -- Include only tables and views
    GROUP BY c.oid, c.relname, c.relkind

    UNION ALL

    -- Functions and Procedures from pg_proc
    SELECT 
        p.oid AS objid,
        p.proname AS object_name,
        CASE 
            WHEN p.prokind = 'f' THEN 'Function'
            WHEN p.prokind = 'p' THEN 'Procedure'
            ELSE 'Unknown'
        END AS object_type,
        string_agg(pg_get_function_arguments(p.oid), ', ') AS columns -- Retrieves function arguments
    FROM pg_proc p
    GROUP BY p.oid, p.proname, p.prokind

    UNION ALL

    -- Operators from pg_operator
    SELECT 
        o.oid AS objid,
        o.oprname AS object_name,
        'Operator' AS object_type,
        o.oprleft::regtype::text || ', ' || o.oprright::regtype::text AS columns -- Operator arguments
    FROM pg_operator o
)
SELECT 
    ext.extname AS extension_name,
    obj.object_name,
    obj.object_type,
    obj.columns AS details
FROM pg_extension ext
JOIN pg_depend dep ON dep.refobjid = ext.oid
JOIN pg_object obj ON obj.objid = dep.objid
--WHERE ext.extname = 'your_extension_name';
WHERE ext.extname = 'pageinspect';


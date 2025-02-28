--create extension if not exists pgagent;
--select * from pg_extension;


WITH pg_object AS (
    -- Objects from pg_class
    SELECT 
        c.oid AS objid,
        c.relname AS object_name,
        CASE 
            WHEN c.relkind = 'r' THEN 'Ordinary table'
            WHEN c.relkind = 'i' THEN 'Index'
            WHEN c.relkind = 'S' THEN 'Sequence'
            WHEN c.relkind = 'v' THEN 'View'
            WHEN c.relkind = 'm' THEN 'Materialized view'
            WHEN c.relkind = 'c' THEN 'Composite type'
            WHEN c.relkind = 't' THEN 'TOAST table'
            WHEN c.relkind = 'f' THEN 'Foreign table'
            WHEN c.relkind = 'p' THEN 'Partitioned table'
            WHEN c.relkind = 'I' THEN 'Partitioned index'
            ELSE 'Unknown'
        END AS object_type
    FROM pg_class c

    UNION ALL

    -- Functions from pg_proc
    SELECT 
        p.oid AS objid,
        p.proname AS object_name,
        'Function' AS object_type
    FROM pg_proc p

    UNION ALL

    -- Types from pg_type
    SELECT 
        t.oid AS objid,
        t.typname AS object_name,
        'Type' AS object_type
    FROM pg_type t

    UNION ALL

    -- Schemas from pg_namespace
    SELECT 
        n.oid AS objid,
        n.nspname AS object_name,
        'Schema' AS object_type
    FROM pg_namespace n

    UNION ALL

    -- Operators from pg_operator
    SELECT 
        o.oid AS objid,
        o.oprname AS object_name,
        'Operator' AS object_type
    FROM pg_operator o

    UNION ALL

    -- Aggregates from pg_aggregate
    SELECT 
        a.aggfnoid AS objid,
        p.proname AS object_name,
        'Aggregate' AS object_type
    FROM pg_aggregate a
    JOIN pg_proc p ON a.aggfnoid = p.oid

    UNION ALL

    -- Event triggers from pg_event_trigger
    SELECT 
        e.oid AS objid,
        e.evtname AS object_name,
        'Event Trigger' AS object_type
    FROM pg_event_trigger e

    UNION ALL

    -- Foreign data wrappers from pg_foreign_data_wrapper
    SELECT 
        f.oid AS objid,
        f.fdwname AS object_name,
        'Foreign Data Wrapper' AS object_type
    FROM pg_foreign_data_wrapper f
)
SELECT 
    ext.extname AS extension_name,
    obj.object_name,
    obj.object_type
FROM pg_extension ext
JOIN pg_depend dep ON dep.refobjid = ext.oid
JOIN pg_object obj ON obj.objid = dep.objid
WHERE ext.extname = 'your_extension_name';


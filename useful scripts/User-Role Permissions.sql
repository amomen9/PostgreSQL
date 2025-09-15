--   AI Contributed Query

/* Extended privileges inventory:
   Includes: TABLE, ANY_COLUMN (has_any_column_privilege), COLUMN (per-column),
             SEQUENCE, DATABASE, SCHEMA, FUNCTION, LANGUAGE, FDW, FOREIGN_SERVER.
   Adds OWNER pseudo-privilege (like original).
   Excludes system schemas (pg_catalog, information_schema) for object-level results.
*/

WITH roles AS (
    SELECT rolname
    FROM pg_roles
    WHERE rolcanlogin
),

-- Helper: all user tables/relations (incl partitioned, foreign) + owners
tables AS (
    SELECT c.oid,
           c.relkind,
           n.nspname AS schema_name,
           c.relname AS rel_name,
           format('%I.%I', n.nspname, c.relname) AS qual_name,
           pg_get_userbyid(c.relowner) AS owner_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r','p','v','m','f')
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),

sequences AS (
    SELECT c.oid,
           format('%I.%I', n.nspname, c.relname) AS qual_name,
           pg_get_userbyid(c.relowner) AS owner_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'S'
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),

schemas AS (
    SELECT n.oid,
           n.nspname AS name,
           pg_get_userbyid(n.nspowner) AS owner_name
    FROM pg_namespace n
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),

functions AS (
    SELECT p.oid,
           format('%I.%I(%s)', n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)) AS qual_name,
           pg_get_userbyid(p.proowner) AS owner_name
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),

languages AS (
    SELECT l.oid,
           l.lanname AS name,
           pg_get_userbyid(l.lanowner) AS owner_name
    FROM pg_language l
    WHERE l.lanname NOT IN ('internal','c')  -- skip internal impl languages
),

fdw AS (
    SELECT f.oid,
           f.fdwname AS name,
           pg_get_userbyid(f.fdwowner) AS owner_name
    FROM pg_foreign_data_wrapper f
),

foreign_srv AS (
    SELECT s.oid,
           s.srvname AS name,
           pg_get_userbyid(s.srvowner) AS owner_name
    FROM pg_foreign_server s
),

databases AS (
    SELECT d.oid,
           d.datname AS name,
           pg_get_userbyid(d.datdba) AS owner_name
    FROM pg_database d
    WHERE d.datname NOT IN ('template0','template1')
),

column_list AS (
    SELECT t.qual_name,
           a.attname AS column_name,
           t.owner_name
    FROM tables t
    JOIN pg_attribute a ON a.attrelid = t.oid
    WHERE a.attnum > 0
      AND NOT a.attisdropped
),

union_selects AS (
	-- UNION ALL privileges per object type
	SELECT r.rolname AS user_name,
		   'TABLE' AS object_type,
		   t.qual_name AS object_name,
		   NULL::text AS column_name,
		   priv AS privilege_type
	FROM roles r
	JOIN tables t ON true
	CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER']) AS g(priv)
	WHERE has_table_privilege(r.rolname, t.qual_name, g.priv)
	UNION ALL
	-- TABLE OWNER
	SELECT r.rolname, 'TABLE', t.qual_name, NULL, 'OWNER'
	FROM roles r
	JOIN tables t ON r.rolname = t.owner_name
	UNION ALL
	-- ANY_COLUMN (aggregated column privileges)
	SELECT r.rolname, 'ANY_COLUMN', t.qual_name, NULL,
		   priv AS privilege_type
	FROM roles r
	JOIN tables t ON true
	CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS g(priv)
	WHERE has_any_column_privilege(r.rolname, t.qual_name, g.priv)
	UNION ALL
	-- COLUMN level
	SELECT r.rolname, 'COLUMN', format('%s(%I)', c.qual_name, c.column_name), c.column_name,
		   priv
	FROM roles r
	JOIN column_list c ON true
	CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS g(priv)
	WHERE has_column_privilege(r.rolname, c.qual_name, c.column_name, g.priv)
	UNION ALL
	-- SEQUENCE privileges
	SELECT r.rolname, 'SEQUENCE', s.qual_name, NULL, priv
	FROM roles r
	JOIN sequences s ON true
	CROSS JOIN LATERAL unnest(ARRAY['SELECT','USAGE','UPDATE']) AS g(priv)
	WHERE has_sequence_privilege(r.rolname, s.qual_name, g.priv)
	UNION ALL
	-- SEQUENCE OWNER
	SELECT r.rolname, 'SEQUENCE', s.qual_name, NULL, 'OWNER'
	FROM roles r
	JOIN sequences s ON r.rolname = s.owner_name
	UNION ALL
	-- DATABASE privileges
	SELECT r.rolname, 'DATABASE', d.name, NULL, priv
	FROM roles r
	JOIN databases d ON true
	CROSS JOIN LATERAL unnest(ARRAY['CONNECT','CREATE','TEMP']) AS g(priv)
	WHERE has_database_privilege(r.rolname, d.name, g.priv)
	UNION ALL
	-- DATABASE OWNER
	SELECT r.rolname, 'DATABASE', d.name, NULL, 'OWNER'
	FROM roles r
	JOIN databases d ON r.rolname = d.owner_name
	UNION ALL
	-- SCHEMA privileges
	SELECT r.rolname, 'SCHEMA', s.name, NULL, priv
	FROM roles r
	JOIN schemas s ON true
	CROSS JOIN LATERAL unnest(ARRAY['USAGE','CREATE']) AS g(priv)
	WHERE has_schema_privilege(r.rolname, s.name, g.priv)
	UNION ALL
	-- SCHEMA OWNER
	SELECT r.rolname, 'SCHEMA', s.name, NULL, 'OWNER'
	FROM roles r
	JOIN schemas s ON r.rolname = s.owner_name
	UNION ALL
	-- FUNCTION (EXECUTE)
	SELECT r.rolname, 'FUNCTION', f.qual_name, NULL, 'EXECUTE'
	FROM roles r
	JOIN functions f ON true
	WHERE has_function_privilege(r.rolname, f.oid, 'EXECUTE')
	UNION ALL
	-- FUNCTION OWNER
	SELECT r.rolname, 'FUNCTION', f.qual_name, NULL, 'OWNER'
	FROM roles r
	JOIN functions f ON r.rolname = f.owner_name
	UNION ALL
	-- LANGUAGE (USAGE)
	SELECT r.rolname, 'LANGUAGE', l.name, NULL, 'USAGE'
	FROM roles r
	JOIN languages l ON true
	WHERE has_language_privilege(r.rolname, l.name, 'USAGE')
	UNION ALL
	-- LANGUAGE OWNER
	SELECT r.rolname, 'LANGUAGE', l.name, NULL, 'OWNER'
	FROM roles r
	JOIN languages l ON r.rolname = l.owner_name
	UNION ALL
	-- FDW (USAGE)
	SELECT r.rolname, 'FDW', w.name, NULL, 'USAGE'
	FROM roles r
	JOIN fdw w ON true
	WHERE has_foreign_data_wrapper_privilege(r.rolname, w.oid, 'USAGE')
	UNION ALL
	-- FDW OWNER
	SELECT r.rolname, 'FDW', w.name, NULL, 'OWNER'
	FROM roles r
	JOIN fdw w ON r.rolname = w.owner_name
	UNION ALL
	-- FOREIGN SERVER (USAGE)
	SELECT r.rolname, 'FOREIGN_SERVER', sv.name, NULL, 'USAGE'
	FROM roles r
	JOIN foreign_srv sv ON true
	WHERE has_server_privilege(r.rolname, sv.oid, 'USAGE')
	UNION ALL
	-- FOREIGN SERVER OWNER
	SELECT r.rolname, 'FOREIGN_SERVER', sv.name, NULL, 'OWNER'
	FROM roles r
	JOIN foreign_srv sv ON r.rolname = sv.owner_name
	ORDER BY user_name, object_type, object_name, privilege_type
)
SELECT *
FROM union_selects
WHERE user_name='dataplatform_ro'
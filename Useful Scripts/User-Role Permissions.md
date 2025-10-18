# 🛡️ PostgreSQL Unified Privilege Inventory Query

---

## 1. Purpose

Enumerate effective privileges for every login-capable role across multiple PostgreSQL object types, adding an `OWNER` pseudo-privilege where the role is the object owner. This inventory supports auditing, least-privilege validation, and compliance reviews.

---

## 2. Object Types Covered

| Object Type | Source Catalog | Privilege Resolution Function |
|-------------|----------------|--------------------------------|
| `TABLE` / `VIEW` / `FOREIGN TABLE` / `MATERIALIZED VIEW` / `PARTITIONED TABLE` | `pg_class` | `has_table_privilege` |
| `ANY_COLUMN` (aggregated) | Derived from table-level | `has_any_column_privilege` |
| `COLUMN` (per column) | `pg_attribute` + `pg_class` | `has_column_privilege` |
| `SEQUENCE` | `pg_class` | `has_sequence_privilege` |
| `DATABASE` | `pg_database` | `has_database_privilege` |
| `SCHEMA` | `pg_namespace` | `has_schema_privilege` |
| `FUNCTION` | `pg_proc` | `has_function_privilege` |
| `LANGUAGE` | `pg_language` | `has_language_privilege` |
| `FDW` | `pg_foreign_data_wrapper` | `has_foreign_data_wrapper_privilege` |
| `FOREIGN_SERVER` | `pg_foreign_server` | `has_server_privilege` |

---

## 3. Features ✨

1. Collects only non-system objects (excludes `pg_catalog`, `information_schema`).
2. Produces a unified, UNION-based result set (`union_selects` CTE).
3. Adds synthetic `OWNER` privilege rows for ownership visibility.
4. Supports column-level and aggregate (ANY_COLUMN) privilege distinctions.
5. Easily filterable (`WHERE user_name='...' AND object_type='...'`).

---

## 4. Usage Steps

### 4.1 Basic Execution
1. Copy the full script.
2. Run in `psql` / `pgAdmin` / any PostgreSQL client.

### 4.2 Filtering
1. Adjust the final `WHERE` clause to narrow by:
   - Role (`user_name`)
   - Object type (`object_type`)
   - Or remove entirely for full inventory.

### 4.3 Extension
1. Add more privilege types (e.g., `RULE`, `TYPE`) using similar patterns.
2. Wrap final query in a view for reuse: `CREATE VIEW privilege_matrix AS <query>;`.

---

## 5. Output Columns

| Column | Meaning |
|--------|---------|
| `user_name` | Role being evaluated. |
| `object_type` | Category (e.g., `TABLE`, `COLUMN`, `SEQUENCE`). |
| `object_name` | Qualified object identifier or composite (for columns). |
| `column_name` | Column (only for `COLUMN` rows). |
| `privilege_type` | Granted or synthetic privilege (`OWNER`). |

---

## 6. Refactored Query 🛠️

```sql
-- User-Role Permissions.sql
-- Extended unified privilege inventory across major object kinds.
-- Includes OWNER pseudo-privilege to surface ownership alongside granted privileges.

WITH roles AS (
    /* 1. Login-capable roles */
    SELECT rolname
    FROM pg_roles
    WHERE rolcanlogin
),

tables AS (
    /* 2. User-visible relations (exclude system schemas) */
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
    /* 3. User sequences */
    SELECT c.oid,
           format('%I.%I', n.nspname, c.relname) AS qual_name,
           pg_get_userbyid(c.relowner) AS owner_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'S'
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),

schemas AS (
    /* 4. Schemas excluding system schemas */
    SELECT n.oid,
           n.nspname AS name,
           pg_get_userbyid(n.nspowner) AS owner_name
    FROM pg_namespace n
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),

functions AS (
    /* 5. Functions (incl procedures, aggregates, windows distinguished by prokind) */
    SELECT p.oid,
           format('%I.%I(%s)', n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)) AS qual_name,
           pg_get_userbyid(p.proowner) AS owner_name
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),

languages AS (
    /* 6. Procedural languages (exclude internal, C) */
    SELECT l.oid,
           l.lanname AS name,
           pg_get_userbyid(l.lanowner) AS owner_name
    FROM pg_language l
    WHERE l.lanname NOT IN ('internal','c')
),

fdw AS (
    /* 7. Foreign Data Wrappers */
    SELECT f.oid,
           f.fdwname AS name,
           pg_get_userbyid(f.fdwowner) AS owner_name
    FROM pg_foreign_data_wrapper f
),

foreign_srv AS (
    /* 8. Foreign Servers */
    SELECT s.oid,
           s.srvname AS name,
           pg_get_userbyid(s.srvowner) AS owner_name
    FROM pg_foreign_server s
),

databases AS (
    /* 9. Databases (exclude templates) */
    SELECT d.oid,
           d.datname AS name,
           pg_get_userbyid(d.datdba) AS owner_name
    FROM pg_database d
    WHERE d.datname NOT IN ('template0','template1')
),

column_list AS (
    /* 10. Column list for all eligible tables */
    SELECT t.qual_name,
           a.attname AS column_name,
           t.owner_name
    FROM tables t
    JOIN pg_attribute a ON a.attrelid = t.oid
    WHERE a.attnum > 0
      AND NOT a.attisdropped
),

union_selects AS (
    /* 11. TABLE privileges */
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
    /* TABLE OWNER pseudo-privilege */
    SELECT r.rolname, 'TABLE', t.qual_name, NULL, 'OWNER'
    FROM roles r
    JOIN tables t ON r.rolname = t.owner_name

    UNION ALL
    /* ANY_COLUMN aggregated privileges */
    SELECT r.rolname, 'ANY_COLUMN', t.qual_name, NULL, priv
    FROM roles r
    JOIN tables t ON true
    CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS g(priv)
    WHERE has_any_column_privilege(r.rolname, t.qual_name, g.priv)

    UNION ALL
    /* COLUMN-level privileges */
    SELECT r.rolname, 'COLUMN',
           format('%s(%I)', c.qual_name, c.column_name) AS object_name,
           c.column_name,
           priv
    FROM roles r
    JOIN column_list c ON true
    CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS g(priv)
    WHERE has_column_privilege(r.rolname, c.qual_name, c.column_name, g.priv)

    UNION ALL
    /* SEQUENCE privileges */
    SELECT r.rolname, 'SEQUENCE', s.qual_name, NULL, priv
    FROM roles r
    JOIN sequences s ON true
    CROSS JOIN LATERAL unnest(ARRAY['SELECT','USAGE','UPDATE']) AS g(priv)
    WHERE has_sequence_privilege(r.rolname, s.qual_name, g.priv)

    UNION ALL
    /* SEQUENCE OWNER */
    SELECT r.rolname, 'SEQUENCE', s.qual_name, NULL, 'OWNER'
    FROM roles r
    JOIN sequences s ON r.rolname = s.owner_name

    UNION ALL
    /* DATABASE privileges */
    SELECT r.rolname, 'DATABASE', d.name, NULL, priv
    FROM roles r
    JOIN databases d ON true
    CROSS JOIN LATERAL unnest(ARRAY['CONNECT','CREATE','TEMP']) AS g(priv)
    WHERE has_database_privilege(r.rolname, d.name, g.priv)

    UNION ALL
    /* DATABASE OWNER */
    SELECT r.rolname, 'DATABASE', d.name, NULL, 'OWNER'
    FROM roles r
    JOIN databases d ON r.rolname = d.owner_name

    UNION ALL
    /* SCHEMA privileges */
    SELECT r.rolname, 'SCHEMA', s.name, NULL, priv
    FROM roles r
    JOIN schemas s ON true
    CROSS JOIN LATERAL unnest(ARRAY['USAGE','CREATE']) AS g(priv)
    WHERE has_schema_privilege(r.rolname, s.name, g.priv)

    UNION ALL
    /* SCHEMA OWNER */
    SELECT r.rolname, 'SCHEMA', s.name, NULL, 'OWNER'
    FROM roles r
    JOIN schemas s ON r.rolname = s.owner_name

    UNION ALL
    /* FUNCTION EXECUTE privilege */
    SELECT r.rolname, 'FUNCTION', f.qual_name, NULL, 'EXECUTE'
    FROM roles r
    JOIN functions f ON true
    WHERE has_function_privilege(r.rolname, f.oid, 'EXECUTE')

    UNION ALL
    /* FUNCTION OWNER */
    SELECT r.rolname, 'FUNCTION', f.qual_name, NULL, 'OWNER'
    FROM roles r
    JOIN functions f ON r.rolname = f.owner_name

    UNION ALL
    /* LANGUAGE USAGE privilege */
    SELECT r.rolname, 'LANGUAGE', l.name, NULL, 'USAGE'
    FROM roles r
    JOIN languages l ON true
    WHERE has_language_privilege(r.rolname, l.name, 'USAGE')

    UNION ALL
    /* LANGUAGE OWNER */
    SELECT r.rolname, 'LANGUAGE', l.name, NULL, 'OWNER'
    FROM roles r
    JOIN languages l ON r.rolname = l.owner_name

    UNION ALL
    /* FDW USAGE privilege */
    SELECT r.rolname, 'FDW', w.name, NULL, 'USAGE'
    FROM roles r
    JOIN fdw w ON true
    WHERE has_foreign_data_wrapper_privilege(r.rolname, w.oid, 'USAGE')

    UNION ALL
    /* FDW OWNER */
    SELECT r.rolname, 'FDW', w.name, NULL, 'OWNER'
    FROM roles r
    JOIN fdw w ON r.rolname = w.owner_name

    UNION ALL
    /* FOREIGN SERVER USAGE privilege */
    SELECT r.rolname, 'FOREIGN_SERVER', sv.name, NULL, 'USAGE'
    FROM roles r
    JOIN foreign_srv sv ON true
    WHERE has_server_privilege(r.rolname, sv.oid, 'USAGE')

    UNION ALL
    /* FOREIGN SERVER OWNER */
    SELECT r.rolname, 'FOREIGN_SERVER', sv.name, NULL, 'OWNER'
    FROM roles r
    JOIN foreign_srv sv ON r.rolname = sv.owner_name

    ORDER BY user_name, object_type, object_name, privilege_type
)

SELECT *
FROM union_selects
WHERE user_name = 'dataplatform_ro'
  AND object_type = 'TABLE';  -- Adjust / remove filter for broader result set
```

---

## 7. Sample Filter Adjustments 🔧

| Scenario | Change |
|----------|--------|
| All roles / all objects | Remove entire `WHERE` clause. |
| Single role audit | `WHERE user_name='reporting_ro'`. |
| Include sequences | `AND object_type='SEQUENCE'`. |
| Column privileges only | `AND object_type='COLUMN'`. |

---

## 8. Extension Ideas 💡

- Add `TYPE` privileges (`pg_type` + `has_type_privilege` in future PostgreSQL versions).
- Persist snapshot daily for drift detection.
- Join with role membership to infer inherited entitlements.

---

## 9. Caveats ⚠️

- Privileges inherited via role membership are not explicitly expanded; evaluation functions (`has_*_privilege`) already consider inheritance.
- `OWNER` pseudo-privilege is artificial—used for clarity, not a real ACL entry.
- Large databases may produce extensive result sets; consider filtering early.

---

## 10. Next Steps ✅

1. Wrap as view:  
   `CREATE VIEW vw_privilege_inventory AS <full query without final WHERE>;`
2. Export:  
   `\copy (SELECT * FROM vw_privilege_inventory) TO 'privileges.csv' CSV HEADER;`
3. Integrate with monitoring for unauthorized grants.

---

**End of Document** ✅
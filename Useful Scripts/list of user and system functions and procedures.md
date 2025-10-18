# 📘 PostgreSQL Function & Procedure Catalog Inventory

---

## 1. Purpose
List every PostgreSQL `function`, `procedure`, `aggregate function`, and `window function`, including schema, return type, argument signatures, language, source body (when available), internal binary reference, and SQL body (if stored). Useful for auditing, documentation, refactoring, or migration assessments.

---

## 2. Output Columns
| Column | Description |
|--------|-------------|
| `function_name` | Unqualified routine name. |
| `schema_name` | Schema where the routine resides. |
| `return_type` | Resolved return type (textual). |
| `argument_types` | Full identity argument list. |
| `language` | Implementation language (e.g., `sql`, `plpgsql`, `internal`). |
| `source_code` | Body (for SQL/PL languages); empty for C/internal. |
| `transformed_return_type_oids` | Internal OID array (rarely needed). |
| `function_kind` | One of: `Function`, `Procedure`, `Aggregate Function`, `Window Function`. |
| `binary_code` | Binary/shared object linkage (for C/internal). |
| `sql_body` | Parsed SQL body (may be NULL depending on version). |

---

## 3. Usage
1. Run as-is for full listing.
2. Optional filtering:
   - By routine name: uncomment `WHERE p.proname LIKE '%partial%'`.
   - By schema: add `AND n.nspname NOT IN ('pg_catalog','information_schema')`.
3. Order preserved: schema then function name.

---

## 4. Steps
1. Collect metadata from `pg_proc`, `pg_namespace`, `pg_language`.
2. Derive kind via `p.prokind`.
3. Retrieve argument list and return type using built-ins.
4. Present ordered inventory.

---

## 5. Refactored Query 🛠️

````sql
-- list of user and system functions and procedures.sql
-- Inventory of all routines (functions/procedures/aggregates/window functions).

SELECT 
    p.proname AS function_name,                              -- Routine name (unqualified)
    n.nspname AS schema_name,                                -- Owning schema
    pg_catalog.pg_get_function_result(p.oid) AS return_type, -- Resolved return type
    pg_catalog.pg_get_function_arguments(p.oid) AS argument_types, -- Argument signature
    l.lanname AS language,                                   -- Implementation language
    p.prosrc AS source_code,                                 -- Source text (for SQL / PL languages)
    p.protrftypes AS transformed_return_type_oids,           -- Internal transformed return types (rare usage)
    CASE                                                     -- Routine classification
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'a' THEN 'Aggregate Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
        WHEN p.prokind = 'w' THEN 'Window Function'
        ELSE 'Unknown'
    END AS function_kind,
    p.probin AS binary_code,                                 -- Binary reference (C/internal)
    p.prosqlbody AS sql_body                                 -- Parsed SQL body (may be NULL)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_language l ON p.prolang = l.oid
-- Optional filters:
-- WHERE p.proname LIKE '%func_or_proc%'    -- Name pattern
--   AND n.nspname NOT IN ('pg_catalog','information_schema')  -- User-defined only
ORDER BY n.nspname, p.proname;
```
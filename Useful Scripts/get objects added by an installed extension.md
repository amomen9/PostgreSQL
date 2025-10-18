# get objects added by an installed extension.sql

Get the names and types and arguments/column names of the objects that creating an extension has added to the database

# 📦 PostgreSQL Extension Object Inventory

---

## 1. Purpose

Identify and list every database object (tables, views, functions, procedures, operators) that was installed by a specific PostgreSQL `extension`, with aggregated details such as column names or function argument signatures.

---

## 2. Key Concepts

| Term | Description |
|------|-------------|
| `pg_extension` | Catalog of installed extensions. |
| `pg_depend` | Dependency graph linking extension OIDs to created objects. |
| `pg_class` | Stores relations (`tables`, `views`). |
| `pg_attribute` | Stores column metadata. |
| `pg_proc` | Stores `functions` and `procedures`. |
| `pg_operator` | Stores operator definitions. |
| `aclexplode` | (Not used here) expands ACL arrays. |

---

## 3. What the Query Does

1. Builds a unified set (`pg_object`) of:
   - Ordinary tables and views (`pg_class` + their columns).
   - Functions and procedures (`pg_proc` + argument list).
   - Operators (`pg_operator` + operand type signatures).
2. Joins this set to `pg_extension` via `pg_depend` to filter objects created specifically by the chosen `extension`.
3. Returns a readable inventory: `extension_name`, `object_name`, `object_type`, and `details`.

---

## 4. Usage Instructions

1. Ensure target extension is installed.
2. Replace `'pageinspect'` in the `WHERE` clause with your desired extension name.
3. Run in `psql`, `pgAdmin`, or other PostgreSQL client.
4. Optional: Uncomment helper lines to inspect installed extensions.

---

## 5. Steps

### 5.1 Preparation
1. (Optional) Create extension if missing.
2. (Optional) List installed extensions.

### 5.2 Execution
1. Execute the full query.
2. Review the resulting object inventory.

### 5.3 Adaptation
1. Add more object categories if needed (e.g., `types`, `operators classes`).
2. Wrap into a view for repeated use.

---

## 6. Refactored Query 🛠️

```sql
-- get objects added by an installed extension.sql
-- Objective: List all objects created by a specific PostgreSQL extension.
-- Supports: Ordinary tables, views, functions, procedures, operators.

-- STEP 1 (Optional): Ensure the extension exists
-- CREATE EXTENSION IF NOT EXISTS pageinspect;

-- STEP 2 (Optional): View all installed extensions
-- SELECT * FROM pg_extension;

WITH pg_object AS (

    /* 1. Tables and Views (from pg_class)
       - Collects oid, name, relkind-derived type, and aggregated column list.
       - Filters relkind to ordinary tables ('r') and views ('v').
    */
    SELECT 
        c.oid AS objid,
        c.relname AS object_name,
        CASE 
            WHEN c.relkind = 'r' THEN 'Ordinary table'
            WHEN c.relkind = 'v' THEN 'View'
            ELSE 'Unknown'
        END AS object_type,
        string_agg(a.attname, ', ') AS columns  -- Aggregated column names
    FROM pg_class c
    LEFT JOIN pg_attribute a
           ON a.attrelid = c.oid
          AND a.attnum > 0
          AND NOT a.attisdropped
    WHERE c.relkind IN ('r', 'v')
    GROUP BY c.oid, c.relname, c.relkind

    UNION ALL

    /* 2. Functions and Procedures (from pg_proc)
       - Includes both 'Function' and 'Procedure' kinds.
       - Aggregates argument signatures (can repeat due to UNION ALL safety).
    */
    SELECT 
        p.oid AS objid,
        p.proname AS object_name,
        CASE 
            WHEN p.prokind = 'f' THEN 'Function'
            WHEN p.prokind = 'p' THEN 'Procedure'
            ELSE 'Unknown'
        END AS object_type,
        string_agg(pg_get_function_arguments(p.oid), ', ') AS columns  -- Function argument list
    FROM pg_proc p
    GROUP BY p.oid, p.proname, p.prokind

    UNION ALL

    /* 3. Operators (from pg_operator)
       - Captures operator name and left/right operand types.
    */
    SELECT 
        o.oid AS objid,
        o.oprname AS object_name,
        'Operator' AS object_type,
        o.oprleft::regtype::text || ', ' || o.oprright::regtype::text AS columns  -- Operand types
    FROM pg_operator o
)

-- Final result: match collected objects to extension-provided ones via pg_depend
SELECT 
    ext.extname AS extension_name,
    obj.object_name,
    obj.object_type,
    obj.columns AS details
FROM pg_extension ext
JOIN pg_depend dep ON dep.refobjid = ext.oid      -- Dependency links extension to objects
JOIN pg_object obj ON obj.objid = dep.objid       -- Only objects installed by the extension
WHERE ext.extname = 'pageinspect';                -- 🔧 Change this to target a different extension
```

---

## 7. Sample Output (Illustrative)

| extension_name | object_name       | object_type     | details                    |
|----------------|-------------------|-----------------|----------------------------|
| pageinspect    | bt_metap          | Function        | relid                      |
| pageinspect    | heap_page_item    | Function        | data bytea                 |
| pageinspect    | page_header       | Function        | data bytea                 |
| pageinspect    | fsm_page_contents | Function        | data bytea                 |

---

## 8. Extension Customization Tips 💡

- To include `types`: join `pg_type` + filter via `pg_depend`.
- To group by object type: add `GROUP BY ext.extname, obj.object_type`.
- To export: run `\copy ( <query> ) TO 'extension_objects.csv' CSV HEADER`.

---

## 9. Caveats ⚠️

- Some extension objects may not appear if they are indirectly referenced (e.g., dependencies on internal objects).
- Functions created in C-language may not expose readable argument bodies beyond their signature.
- Large argument lists may appear duplicated due to `string_agg` over single-row; safe because of grouping.

---

## 10. Next Steps ✅

1. Wrap this query in a view: `CREATE VIEW extension_object_inventory AS <query>;`
2. Parameterize extension name via `psql` variable: `\set extname 'hstore'`.
3. Automate auditing across all extensions.

---

**End of Document** ✨
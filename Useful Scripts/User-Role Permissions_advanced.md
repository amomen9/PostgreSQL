# 1. User-Role Permissions (Advanced) 🧩

Purpose: Inventory object privileges (tables, columns, sequences, schemas, databases, functions, languages, FDWs, foreign servers) across non-system schemas. Converts OIDs to human-readable role names (incl. PUBLIC) and exposes grantor/grantee, owner.

Key Points:
- Uses layered CTEs for object collection and ACL expansion (`aclexplode`).
- Normalizes grantor/grantee resolution (fallback to `pg_get_userbyid`).
- Easily extensible to add more object kinds.
- Final SELECT shows table privileges; adapt for others.

Refactoring:
- Added consistent inline comments.
- Grouped object collectors + ACL expansion.
- Kept recursion placeholder (login_roles + inheritance) though not used in final SELECT—retain if you later add inherited role resolution.

```sql
/* User-Role Permissions_advanced.sql
   Privilege inventory (tables, columns, sequences, schemas, databases, functions, languages, FDW, foreign servers)
   OIDs resolved to names; includes PUBLIC (OID 0).
   Refactored with structured comments.
*/

WITH RECURSIVE login_roles AS (               -- Roles that can log in
    SELECT oid, rolname
    FROM pg_roles
    WHERE rolcanlogin
),
role_inheritance AS (                         -- (Future use) Role membership graph
    SELECT oid AS role_oid, oid AS member_of
    FROM pg_roles
    UNION ALL
    SELECT ri.role_oid, m.roleid AS member_of
    FROM role_inheritance ri
    JOIN pg_auth_members m ON m.member = ri.member_of
    WHERE ri.member_of <> m.roleid
),

role_name AS (                                -- Map OID→name with synthetic PUBLIC (0)
    SELECT oid, rolname FROM pg_roles
    UNION ALL
    SELECT 0::oid, 'PUBLIC'
),

tables AS (                                   -- Tables, partitioned tables, views, materialized views, foreign tables
    SELECT c.oid,
           c.relkind,
           n.nspname AS schema_name,
           c.relname AS rel_name,
           format('%I.%I', n.nspname, c.relname) AS qual_name,
           c.relowner AS owner_oid,
           pg_get_userbyid(c.relowner) AS owner_name,
           COALESCE(c.relacl, '{}'::aclitem[]) AS relacl
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r','p','v','m','f')
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),

table_acl AS (                                -- Expanded table ACL rows
    SELECT t.oid,
           x.grantor,
           x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type,
           x.is_grantable
    FROM tables t
    LEFT JOIN LATERAL aclexplode(t.relacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

column_acl AS (                               -- Column-level ACLs
    SELECT t.oid AS relid,
           a.attname,
           x.grantor,
           x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type,
           x.is_grantable
    FROM tables t
    JOIN pg_attribute a ON a.attrelid = t.oid
    LEFT JOIN LATERAL aclexplode(COALESCE(a.attacl,'{}'::aclitem[])) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
    WHERE a.attnum > 0 AND NOT a.attisdropped
),

sequences AS (                                -- Sequences
    SELECT c.oid,
           format('%I.%I', n.nspname, c.relname) AS qual_name,
           c.relowner AS owner_oid,
           pg_get_userbyid(c.relowner) AS owner_name,
           COALESCE(c.relacl,'{}'::aclitem[]) AS relacl
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind='S'
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),
sequence_acl AS (
    SELECT s.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM sequences s
    LEFT JOIN LATERAL aclexplode(s.relacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

schemas AS (                                  -- Schemas
    SELECT n.oid,
           n.nspname AS name,
           n.nspowner AS owner_oid,
           pg_get_userbyid(n.nspowner) AS owner_name,
           COALESCE(n.nspacl,'{}'::aclitem[]) AS nspacl
    FROM pg_namespace n
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),
schema_acl AS (
    SELECT s.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM schemas s
    LEFT JOIN LATERAL aclexplode(s.nspacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

databases AS (                                -- Databases except templates
    SELECT d.oid,
           d.datname AS name,
           d.datdba AS owner_oid,
           pg_get_userbyid(d.datdba) AS owner_name,
           COALESCE(d.datacl,'{}'::aclitem[]) AS datacl
    FROM pg_database d
    WHERE d.datname NOT IN ('template0','template1')
),
database_acl AS (
    SELECT d.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM databases d
    LEFT JOIN LATERAL aclexplode(d.datacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

functions AS (                                -- Functions with signature context
    SELECT p.oid,
           format('%I.%I(%s)', n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)) AS qual_name,
           p.proowner AS owner_oid,
           pg_get_userbyid(p.proowner) AS owner_name,
           COALESCE(p.proacl,'{}'::aclitem[]) AS proacl
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname NOT IN ('pg_catalog','information_schema')
),
function_acl AS (
    SELECT f.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM functions f
    LEFT JOIN LATERAL aclexplode(f.proacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

languages AS (                                -- Procedural languages (skip internal)
    SELECT l.oid,
           l.lanname AS name,
           l.lanowner AS owner_oid,
           pg_get_userbyid(l.lanowner) AS owner_name,
           COALESCE(l.lanacl,'{}'::aclitem[]) AS lanacl
    FROM pg_language l
    WHERE l.lanname NOT IN ('internal','c')
),
language_acl AS (
    SELECT l.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM languages l
    LEFT JOIN LATERAL aclexplode(l.lanacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

fdws AS (                                     -- Foreign data wrappers
    SELECT f.oid,
           f.fdwname AS name,
           f.fdwowner AS owner_oid,
           pg_get_userbyid(f.fdwowner) AS owner_name,
           COALESCE(f.fdwacl,'{}'::aclitem[]) AS fdwacl
    FROM pg_foreign_data_wrapper f
),
fdw_acl AS (
    SELECT f.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM fdws f
    LEFT JOIN LATERAL aclexplode(f.fdwacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
),

foreign_servers AS (                          -- Foreign servers
    SELECT s.oid,
           s.srvname AS name,
           s.srvowner AS owner_oid,
           pg_get_userbyid(s.srvowner) AS owner_name,
           COALESCE(s.srvacl,'{}'::aclitem[]) AS srvacl
    FROM pg_foreign_server s
),
foreign_server_acl AS (
    SELECT s.oid, x.grantor, x.grantee,
           COALESCE(rg.rolname, pg_get_userbyid(x.grantee)) AS grantee_name,
           COALESCE(rgr.rolname, pg_get_userbyid(x.grantor)) AS grantor_name,
           x.privilege_type, x.is_grantable
    FROM foreign_servers s
    LEFT JOIN LATERAL aclexplode(s.srvacl) x ON true
    LEFT JOIN role_name rg  ON rg.oid  = x.grantee
    LEFT JOIN role_name rgr ON rgr.oid = x.grantor
)

/* Example output: table privileges with names instead of OIDs */
SELECT
    t.schema_name,
    t.rel_name AS table_name,
    ta.grantee_name,
    ta.privilege_type,
    ta.is_grantable,
    ta.grantor_name,
    t.owner_name
FROM tables t
LEFT JOIN table_acl ta ON ta.oid = t.oid
ORDER BY t.schema_name, t.rel_name, ta.grantee_name NULLS LAST, ta.privilege_type;
```

---
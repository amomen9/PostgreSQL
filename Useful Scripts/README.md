# 🗂️ PostgreSQL Useful Scripts Index

---

## 1. Overview

> The following files are some useful scripts that PostgreSQL DBAs and Developers can use to obtain some  
> metadata or information about PostgreSQL or its databases. They also instruct the user to perform some of the  
> most frequent modifications. These scripts will be enhanced and some new scripts and functionalities will be  
> added over time. These are the scripts:

---

## 2. Quick Access Index 🔗

### 2.1 Script Links

1. [`active error log reader.sql`](active%20error%20log%20reader.sql)  
2. [`get objects added by an installed extension.sql`](get%20objects%20added%20by%20an%20installed%20extension.sql)  
3. [`GRANT Permission TO only some tables.sql`](GRANT%20Permission%20TO%20only%20some%20tables.sql)  
4. [`list of user and system functions and procedures.sql`](list%20of%20user%20and%20system%20functions%20and%20procedures.sql)  
5. [`pg_class (relations) report.sql`](pg_class%20(relations)%20report.sql)  
6. [`User-Role Permissions.sql`](User-Role%20Permissions.sql)  
7. [`User-Role Permissions_advanced.sql`](User-Role%20Permissions_advanced.sql)  

---

## 3. Script Catalog Table 📋

| # | Script | Category | Summary |
|---|--------|----------|---------|
| 1 | `active error log reader.sql` | Monitoring | Reads active server log excerpts. |
| 2 | `get objects added by an installed extension.sql` | Extension Audit | Lists objects created by a specific `extension`. |
| 3 | `GRANT Permission TO only some tables.sql` | Security | Applies least‑privilege `GRANT` / `REVOKE` patterns. |
| 4 | `list of user and system functions and procedures.sql` | Introspection | Inventories all routines with metadata. |
| 5 | `pg_class (relations) report.sql` | Catalog | Reports relation (`pg_class`) structure and stats. |
| 6 | `User-Role Permissions.sql` | Access Matrix | Unified privilege snapshot (high level). |
| 7 | `User-Role Permissions_advanced.sql` | Access Deep Dive | Detailed ACL expansion across object types. |

---

## 4. How to Use 🚀

### 4.1 Steps

1. Identify need (e.g., `privilege audit`, `extension validation`, `log inspection`).
2. Open corresponding `.sql` file from this index.
3. Review internal comments (where present).
4. Execute in a controlled environment (`psql`, `pgAdmin`, CI harness).

### 4.2 Optional Enhancements

1. Create a `VIEW` from frequently used queries.  
2. Schedule periodic exports (`\copy`) for compliance.  
3. Track modified versions in `git` with commit messages including `script` tag.

---

## 5. Recommended Workflow 🧩

1. `Security` Review → Run `User-Role Permissions.sql` then `User-Role Permissions_advanced.sql`.  
2. `Extension` Audit → Use `get objects added by an installed extension.sql`.  
3. `Performance / Catalog` Insight → Query via `pg_class (relations) report.sql`.  
4. `Routine Inventory` → Execute `list of user and system functions and procedures.sql`.  
5. `Access Hardening` → Apply `GRANT Permission TO only some tables.sql`.  
6. `Operational Check` → Inspect logs with `active error log reader.sql`.

---

## 6. Maintenance & Growth 🌱

| Area | Action |
|------|--------|
| `Documentation` | Add inline comments and version headers. |
| `Versioning` | Tag releases (e.g., `v1.1-priv-matrix`). |
| `Testing` | Validate on staging before production usage. |
| `Enhancements` | Expand advanced privileges to include `TYPE`, `DOMAIN`, `OPERATOR CLASS` later. |

---

## 7. Glossary 🔍

| Term | Meaning |
|------|--------|
| `ACL` | Access Control List (privileges array). |
| `OID` | Object Identifier in system catalogs. |
| `Extension` | Packaged set of SQL objects installed atomically. |
| `Privilege` | Action right (e.g., `SELECT`, `USAGE`, `EXECUTE`). |
| `Schema` | Namespace grouping objects. |

---

## 8. Roadmap 🧭

1. Add `script` to export role membership graph.
2. Introduce index usage report via `pg_stat_user_indexes`.
3. Provide vacuum / bloat estimator utilities.
4. Integrate alerting triggers for unauthorized `GRANT`.

---

## 9. Integrity Checklist ✅

- [ ] All filenames present and linked.  
- [ ] No system objects modified directly.  
- [ ] Scripts reviewed for `DROP` risk.  
- [ ] Privilege scripts run inside `TRANSACTION`.  

---

## 10. Final Notes ✨

Use these curated `scripts` as a foundation for deeper PostgreSQL observability and governance; evolve them with environment‑specific metadata needs.

---
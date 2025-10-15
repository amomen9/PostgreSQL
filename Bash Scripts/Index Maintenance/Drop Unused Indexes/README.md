# 🐘 PostgreSQL Stats Reset Script

Small utility to reset cumulative PostgreSQL statistics cluster-wide using `pg_stat_reset()`.

## 🔧 Purpose
Resets internal performance/stat counters (e.g., tables/index usage, function stats) across the cluster. Useful before workload benchmarking or after maintenance to start from a clean baseline.

## ⚠️ Effects
- Affects all databases (function is cluster-scoped even when run connected to one DB).
- Does NOT remove data; only clears accumulated stats views like `pg_stat_all_tables`, `pg_stat_database`, etc.
- Do not run during analytical collection windows unless intentional.

## ▶️ Usage
```bash
./reset_pg_stats.sh mydb
```
Requires:
- Shell user with permission to sudo as `postgres`.
- `psql` in PATH.

## 💡 When To Use
- Before performance test runs.
- After bulk loads / maintenance to measure fresh behavior.
- To validate that certain queries are hitting expected objects.

## 📄 Script

```bash
#!/usr/bin/env bash
# Reset PostgreSQL cumulative statistics using pg_stat_reset().
# Usage: reset_pg_stats.sh <database_name>

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <database_name>" >&2
  exit 1
fi

DB_NAME="$1"

# Invoke psql as postgres OS user and perform stats reset
sudo -u postgres psql -d "$DB_NAME" -c "SELECT pg_stat_reset();"
```

## ✅ Notes
- The database name argument is only for connection; reset scope is still global.
- For per-database reset (PostgreSQL 14+), consider `SELECT pg_stat_reset_shared('bgwriter');` and newer granular functions where applicable.

## 🧪 Validation
After running:
```sql
SELECT * FROM pg_stat_database ORDER BY xact_commit DESC;
```
You should see low (often zero) counters except for activity after the reset.

---



# 🗑️ PostgreSQL Drop Unused Indexes Script

Utility shell script to identify and drop user-created, non-unique, non-constraint indexes that have never been scanned (idx_scan = 0) in the target database.

---

## 🎯 Purpose
Reclaims storage and reduces write amplification / maintenance overhead (VACUUM, autovacuum, checkpoint, WAL) by removing dead-weight indexes that are not used by queries.

---

## ⚙️ How It Works
1. Connects to the specified database via `psql` as the `postgres` OS user (sudo).
2. Queries `pg_stat_user_indexes` joined to `pg_index` filtering:
   - `idx_scan = 0` (never used since stats last reset or server start)
   - Excludes primary / unique / constraint-backed indexes
   - Excludes expression/system/internal indexes via system views logic
   - Excludes invalid indkey = all zeros (ensures real column mapping)
3. Orders candidates by on-disk size (`pg_relation_size`) largest first.
4. Pipes the list through simple text trimming (`tail` / `head`) to strip psql header/footer.
5. Drops each index using `DROP INDEX schema.indexname`.

---

## ⚠️ Warnings
- Stats may have been reset recently (false positives). Verify with workload window.
- Dropping an index is irreversible without rebuild (use `REINDEX` / recreate).
- Does not consider partial or expression indexes explicitly; ensure none are critical.
- Run on a staging copy first or log the candidate list before executing drops.

---

## ▶️ Usage
```bash
./drop_unused_idx.sh my_database
```
Requires:
- Passwordless sudo rights for `postgres` user
- psql in PATH
- Sufficient privileges to drop indexes

To preview only:
```bash
sudo -u postgres psql -d my_database -c "SELECT concat(s.schemaname,'.',s.indexrelname) FROM pg_catalog.pg_stat_user_indexes s JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid WHERE s.idx_scan = 0 AND 0 <>ALL (i.indkey) AND NOT i.indisunique AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_constraint c WHERE c.conindid = s.indexrelid) ORDER BY pg_relation_size(s.indexrelid) DESC;"
```

---

## 🧪 Post-Run Validation
Check for unexpected plan regressions:
```sql
SELECT relname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY relname;
```

Monitor slow query logs or pg_stat_statements after cleanup.

---

## 🛡️ Safe Practices
- Snapshot the candidate list to a file before dropping.
- Consider a dry-run mode enhancement (replace final xargs with echo).
- Exclude large partition parents if using declarative partitioning (extend WHERE clause).
- Retain a recent base backup for rollback.

---

## 📄 Script

```bash
#set -x

dbname=$1

psqlc="sudo -u postgres psql -d$dbname"
#$psqlc

$psqlc -c "SELECT concat(s.schemaname,'.',s.indexrelname) FROM pg_catalog.pg_stat_user_indexes s JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid WHERE s.idx_scan = 0 AND 0 <>ALL (i.indkey) AND NOT i.indisunique AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_constraint c WHERE c.conindid = s.indexrelid) ORDER BY pg_relation_size(s.indexrelid) DESC;" | tail -n +3 | head -n -2 | xargs -I{} $psqlc -c'drop index {}'
```

---

## 🔁 Possible Enhancements
- Add shebang + strict mode (`#!/usr/bin/env bash` + `set -euo pipefail`)
- Add `--echo-all` toggle for auditing
- Implement a `--dry-run` flag
- Filter out indexes younger than N minutes (join pg_class.relfilenode age)

---

🌟 End
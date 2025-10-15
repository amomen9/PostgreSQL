Use these scripts to reindex user indexes inside all databases except the original pre-installed PostgreSQL databases.
Refer to this URL for a full instruction on how to execute these scripts:
https://amdbablog.blogspot.com/2022/01/postgresqls-index-maintenance-b-tree.html

Execution Command:

/bin/sh reindex_userindexes.sh <PG version> <Target Leaf Fragmentation Threshold (0-100)>

Sample Execution command:

/bin/sh reindex_userindexes.sh 14 30

You must execute the script using /bin/sh


---



# 🔧 PostgreSQL Single Index Rebuild Utility

This document describes the purpose and usage of the `reindex_index.sh` script, which performs a concurrent rebuild of a single PostgreSQL index while logging its activity.

---

## 🗂 Overview

The script:
- Accepts a database name, an index identifier, and a log file path.
- Derives the actual index name from the portion after the last dot in the second argument.
- Executes a `REINDEX INDEX CONCURRENTLY` to rebuild the specified index with minimal locking.
- Appends all output (stdout + stderr) to the provided log file.

---

## 🚀 Use Case

Use this utility when:
- An individual index shows high bloat or poor performance.
- You prefer not to lock writes for the entire table (uses `CONCURRENTLY`).
- You already have a list of candidate indexes (perhaps from `pg_stat_user_indexes` / bloat reports) and are iterating through them.

---

## ⚠️ Notes & Constraints

| Aspect | Detail |
|--------|--------|
| Concurrency | `REINDEX INDEX CONCURRENTLY` requires extra passes; slightly longer runtime. |
| Permissions | Requires a role with sufficient privileges (script runs via `sudo -u postgres`). |
| Failure Handling | Script exits only if the shell is configured externally; no explicit error trap. |
| Index Name Derivation | Anything before the last `.` in argument 2 is discarded (e.g., `schema.idx_name` → `idx_name`). Assumes the index is resolvable without schema qualification (search_path). |

If your environment has multiple schemas with identical index names, adjust the script to retain schema qualification.

---

## ▶️ Usage

```bash
./reindex_index.sh mydb public.my_index /var/log/pg/reindex_my_index.log
```

Arguments:
1. Database name (e.g., `mydb`)
2. Raw index token (e.g., `public.my_index` or any dotted string; only final segment is used)
3. Log file path (output is appended)

---

## 🧪 Verification

After running:
```sql
SELECT relname, last_vacuum, last_autovacuum
FROM pg_stat_all_indexes
WHERE relname = 'my_index';
```

Check the log file for completion confirmation or errors:
```
tail -f /var/log/pg/reindex_my_index.log
```

---

## 🛠 Script

```bash
#!/usr/bin/env bash
# Reindex a single PostgreSQL index concurrently.
# Args:
#   $1 = database name
#   $2 = original index identifier (e.g. schema.index_name or path-like token)
#   $3 = log file path (append mode)
# Notes:
#   The index name used for REINDEX is derived from the text after the last dot in $2.
#   This mirrors original behavior and assumes that name is resolvable without schema qualification.

# Append all stdout/stderr to the provided log file
exec >> "$3" 2>&1

# Visual separator (newline) then echo the raw second argument
printf "\n"
echo "$2"

# Derive the bare index name (strip everything up to last '.')
TEMP="$2"
TEMP="${TEMP##*.}"

# Perform the concurrent reindex (same command semantics as original)
sudo -u postgres psql -d"$1" -c "REINDEX INDEX CONCURRENTLY $TEMP"
```

---

## 💡 Enhancement Ideas

| Enhancement | Benefit |
|-------------|---------|
| Add schema qualification | Avoid ambiguity across schemas. |
| Add error trapping (`set -euo pipefail`) | Safer scripting in pipelines. |
| Validate index existence before running | Early failure clarity. |
| Support list mode | Batch process via file input. |
| Capture timing metrics | Benchmark rebuild durations. |

---

## ✅ Summary

A lean utility for targeted, low-lock index maintenance—ideal for scripted index hygiene workflows.

---



# 🛠️ PostgreSQL User Database Index Rebuild Utility

This document explains the purpose and inner workings of the `reindex_usertables.sh` maintenance script.  
It scans all non-template PostgreSQL databases, evaluates B‑Tree indexes for leaf page fragmentation using `pgstatindex()` (from the `pgstattuple` extension), and invokes a separate per-index rebuild script (`reindex.sh` assumed in PATH) for those exceeding a specified fragmentation threshold.

---

## 📌 Script Goals

- Ensure `pgstattuple` is available in every user database (creates the extension if missing).
- Discover candidate fragmented B‑Tree indexes (excluding system and internal ones).
- Rebuild (concurrently) only those whose `leaf_fragmentation` meets or exceeds a supplied threshold.
- Produce a timestamped log detailing the run and its duration.

---

## ⚙️ Arguments

| Position | Meaning | Example |
|----------|---------|---------|
| `$1` | PostgreSQL major version (used to build binary path `/usr/pgsql-$1/bin`) | `13` |
| `$2` | Fragmentation threshold (numeric; compared to `leaf_fragmentation`) | `20` |

---

## 🧪 Fragmentation Logic

The script runs, per database:
```sql
SELECT concat('.', indrelid::regclass, '.', relname)
FROM pg_index i
JOIN pg_class t ON i.indexrelid = t.oid
JOIN pg_opclass opc ON i.indclass[0] = opc.oid
JOIN pg_am ON opc.opcmethod = pg_am.oid
CROSS JOIN LATERAL pgstatindex(i.indexrelid) s
WHERE t.relkind = 'i'
  AND pg_am.amname = 'btree'
  AND leaf_fragmentation >= <threshold>
  AND leaf_fragmentation <> 'NaN'
  AND t.relname NOT LIKE 'pg_%';
```
Filtered indexes are piped to an external `reindex.sh` driver (assumed to perform `REINDEX INDEX CONCURRENTLY`).

---

## 🧾 Logging

All activity is appended to:
```
/var/log/pgsql/maintenance/reindex_job.log
```
Includes:
- Start banner
- Extension creation attempts
- Fragmented index enumeration
- Completion banner with elapsed runtime (high‑precision seconds)

---

## ⚠️ Operational Notes

| Topic | Detail |
|-------|--------|
| Concurrency | Fragmentation evaluation is read-only; rebuild concurrency depends on called script. |
| Accuracy | `leaf_fragmentation` is from `pgstatindex`; large indexes may cost I/O to sample. |
| Safety | System indexes excluded by name pattern (`pg_%`), but consider adding schema filters if needed. |
| Dependencies | Requires: `pgstattuple` extension, `sudo` privileges to run `psql` as `postgres`, GNU coreutils, `bc`. |
| Assumptions | A companion `./reindex.sh` script exists and accepts: `<db> <index> <logfile>`. |

---

## 🚀 Example Invocation

```bash
./reindex_usertables.sh 14 25
```
Meaning: evaluate all user DBs using PostgreSQL 14 binaries; rebuild indexes with ≥25% leaf fragmentation.

---

## 🧩 Enhancement Ideas

| Improvement | Benefit |
|-------------|---------|
| Add dry-run mode | Review candidates without executing rebuilds |
| Parallelize per DB | Faster on multi-core systems |
| Capture row count & size | Prioritize largest wasted space |
| Schema allow/deny lists | Limit scope to specific tenants |
| Structured JSON log | Easier downstream ingestion |

---

## 🧱 Full Script

```bash
#!/usr/bin/env bash
# Reindex B‑Tree indexes whose leaf page fragmentation exceeds a threshold across all user DBs.
# Args:
#   $1 = PostgreSQL major version (used to build PGHOME path, e.g. 13 -> /usr/pgsql-13/bin)
#   $2 = fragmentation threshold (leaf_fragmentation percent from pgstatindex)
# Logs:
#   Appends progress and timings to LOG_PATH.

set -x

################################ Configuration ################################
LOG_DIRECTORY=/var/log/pgsql/maintenance/
LOG_FILE_NAME=reindex_job.log
PGHOME=/usr/pgsql-"$1"/bin
fragmentation_threshold=$2
###############################################################################

LOG_PATH="${LOG_DIRECTORY}${LOG_FILE_NAME}"
alias FULL_DATE='date "+%Y-%m-%d %T.%N %z"'

mkdir -p "${LOG_DIRECTORY}"
touch "${LOG_PATH}"
export PATH="$PATH:$PGHOME"

START_TIMESTAMP=$(date "+%s.%N")

printf "\n------------------------------------------------------------------------------------------------\n$(FULL_DATE):\tStarting reindex maintenance operation\n" >> "${LOG_PATH}" 2>&1

printf "$(FULL_DATE):\tEnsuring pgstattuple extension exists in user databases (requires contrib package)\n\n" >> "${LOG_PATH}" 2>&1
echo $(sudo -u postgres psql -t -c "select datname from pg_database where datname not in ('postgres','template0','template1');" \
  | head -n -1 \
  | xargs -I {} sudo -u postgres psql -d{} postgres -c "create extension if not exists pgstattuple;") >> "${LOG_PATH}" 2>&1

printf "\n$(FULL_DATE):\tReindexing target user indexes:\n" >> "${LOG_PATH}" 2>&1
printf "Index name format: <DBName>.[schema if not public.]<Table>.<Index>\n" >> "${LOG_PATH}" 2>&1

echo $(sudo -u postgres psql -t -c "select datname from pg_database where datname not in ('postgres','template0','template1');" \
  | head -n -1 \
  | xargs -I {} bash -c \
  "sudo -u postgres psql -t -d{} postgres -c \"SELECT concat('.',indrelid::regclass,'.',relname)
       FROM pg_index AS i
       JOIN pg_class AS t ON i.indexrelid = t.oid
       JOIN pg_opclass AS opc ON i.indclass[0] = opc.oid
       JOIN pg_am ON opc.opcmethod = pg_am.oid
       CROSS JOIN LATERAL pgstatindex(i.indexrelid) AS s
       WHERE t.relkind = 'i'
         AND pg_am.amname = 'btree'
         AND leaf_fragmentation >= ${fragmentation_threshold}
         AND leaf_fragmentation <> 'NaN'
         AND t.relname NOT LIKE 'pg_%'\" \
    | head -n -1 | tr -d ' ' | sed -e 's/^/{}/' | xargs -IA ./reindex.sh {} A \"${LOG_PATH}\"")

END_TIMESTAMP=$(date "+%s.%N")
EXECUTION_TIME=$(bc <<< "${END_TIMESTAMP}-${START_TIMESTAMP}")

printf "\n\n$(FULL_DATE):\tProcess finished. Total duration: ${EXECUTION_TIME} seconds.\n\n\n\n" >> "${LOG_PATH}" 2>&1
```

---

## ✅ Summary

This script automates fragmentation-driven index maintenance across all user databases, providing consistent logging and modular rebuild invocation.

---
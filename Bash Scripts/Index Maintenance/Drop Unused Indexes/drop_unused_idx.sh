#!/usr/bin/env bash
# Drop non-unique, non-constraint user indexes never scanned (idx_scan=0)

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <database_name>" >&2
  exit 1
fi

DB_NAME="$1"
PSQL_CMD="sudo -u postgres psql -d${DB_NAME}"

# List candidate indexes then drop each (excludes PK/unique/constraint & expression/system)
$PSQL_CMD -c "SELECT concat(s.schemaname,'.',s.indexrelname)
              FROM pg_catalog.pg_stat_user_indexes s
              JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
              WHERE s.idx_scan = 0
                AND 0 <> ALL (i.indkey)
                AND NOT i.indisunique
                AND NOT EXISTS (
                      SELECT 1
                      FROM pg_catalog.pg_constraint c
                      WHERE c.conindid = s.indexrelid)
              ORDER BY pg_relation_size(s.indexrelid) DESC;" \
| tail -n +3 | head -n -2 | xargs -I{} $PSQL_CMD -c "DROP INDEX {}"
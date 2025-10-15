#!/usr/bin/env bash
# Reset PostgreSQL cumulative statistics (cluster-wide) using pg_stat_reset().
# Usage: reset_pg_stats.sh <database_name>

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <database_name>" >&2
  exit 1
fi

DB_NAME="$1"

# Invoke psql as postgres OS user and perform stats reset
sudo -u postgres psql -d "$DB_NAME" -c "SELECT pg_stat_reset();"
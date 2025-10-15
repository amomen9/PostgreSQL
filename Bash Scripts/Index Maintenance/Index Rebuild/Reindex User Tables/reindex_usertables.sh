###################################################################
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
###################################################################

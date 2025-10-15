###################################################################
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
##################################################################

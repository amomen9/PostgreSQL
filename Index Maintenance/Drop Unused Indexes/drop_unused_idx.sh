#set -x

dbname=$1


psqlc="sudo -u postgres psql -d$dbname"
#$psqlc

$psqlc -c "SELECT concat(s.schemaname,'.',s.indexrelname) FROM pg_catalog.pg_stat_user_indexes s JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid WHERE s.idx_scan = 0 AND 0 <>ALL (i.indkey) AND NOT i.indisunique AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_constraint c WHERE c.conindid = s.indexrelid) ORDER BY pg_relation_size(s.indexrelid) DESC;" | tail -n +3 | head -n -2 | xargs -I{} $psqlc -c'drop index {}'



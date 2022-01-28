#set -x

dbname=$1


psqlc="sudo -u postgres psql -d$dbname"
#$psqlc

$psqlc -c "SELECT pg_stat_reset();"



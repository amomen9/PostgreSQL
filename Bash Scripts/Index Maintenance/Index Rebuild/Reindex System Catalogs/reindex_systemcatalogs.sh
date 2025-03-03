###################################################################
set -x

######## variables: ##############

LOG_DIRECTORY=/var/log/pgsql/maintenance/
LOG_FILE_NAME=reindex_job.log
PGHOME=/usr/pgsql-$1/bin        #Home for PG13: /usr/pgsql-13/bin
fragmentation_threshold=$2

###############################

#exec > >(logger -i -p local1.info) 2>&1

LOG_PATH=$LOG_DIRECTORY$LOG_FILE_NAME
alias FULL_DATE='date "+%Y-%m-%d %T.%N %z"'
mkdir -p /var/log/pgsql/maintenance/
touch $LOG_PATH
export PATH=$PATH:$PGHOME


START_TIMESTAMP=$(echo $(date "+%s.%N"))


printf "\------------------------------------------------------------------------------------------------\n$(FULL_DATE):\tStarting reindex maintenance operation  \n" >> $LOG_PATH 2>&1



printf "$(FULL_DATE):\tAdding pgstattuple extension to PostgreSQL's databases if not already added: \
(Attention! \"postgresql<pg version>-contrib\" package must be installed in advance\n\n" >> $LOG_PATH 2>&1
echo $(sudo -u postgres psql -t -c "select datname from pg_database where datname not in ('postgres','template0','template1');"\
 | head -n -1 | xargs -I {} sudo -u postgres psql -d{} postgres -c "create extension if not exists pgstattuple;") >> $LOG_PATH 2>&1

printf "\n$(FULL_DATE):\tReindexing target user indexes:\n" >> $LOG_PATH 2>&1
printf "The index names will be in format: \"<DBName>.[schema name if not public.]<Table Name>.<Index Name>\"\n" >> $LOG_PATH 2>&1



echo $(sudo -u postgres psql -t -c "select datname from pg_database where datname \
 not in ('postgres','template0','template1');" | head -n -1 | xargs -I {}  bash -c \
 "sudo -u postgres psql -t -d{} postgres -c \"SELECT concat('.',indrelid::regclass,'.',relname) \
 FROM pg_index AS i JOIN pg_class AS t ON i.indexrelid = t.oid JOIN pg_opclass AS opc \
 ON i.indclass[0] = opc.oid   JOIN pg_am ON opc.opcmethod = pg_am.oid   \
 CROSS JOIN LATERAL pgstatindex(i.indexrelid) AS s \
 WHERE t.relkind = 'i'  AND pg_am.amname = 'btree' and leaf_fragmentation >= $fragmentation_threshold \
 and leaf_fragmentation <> 'NaN' and t.relname like 'pg_%'\" | head -n -1 | tr -d ' ' | sed -e 's/^/{}/' | \
 xargs -IA ./reindex.sh {} A $LOG_PATH") 
 



END_TIMESTAMP=$(echo $(date "+%s.%N"))
#EXECUTION_TIME=$(expr $(date "+%s") - $START_TIMESTAMP)
EXECUTION_TIME=$(bc <<< "$END_TIMESTAMP-$START_TIMESTAMP")


printf "\n\n$(FULL_DATE):\t Process finished executing. The entire process took $EXECUTION_TIME seconds to complete.\n\n\n\n" >> $LOG_PATH 2>&1
###################################################################

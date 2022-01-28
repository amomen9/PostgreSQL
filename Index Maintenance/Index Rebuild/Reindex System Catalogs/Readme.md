Use these scripts to reindex system catalogs' indexes inside all databases except the original pre-installed PostgreSQL databases.
Refer to this URL for a full instruction on how to execute these scripts:
https://amdbablog.blogspot.com/2022/01/postgresqls-index-maintenance-b-tree.html

Execution Command:

/bin/sh reindex_userindexes.sh <PG version> <Target Leaf Fragmentation Threshold (0-100)>

Sample Execution command:

/bin/sh reindex_systemcatalogs.sh 14 30

You must execute the script using /bin/sh. Note that you cannot reindex system catalogs concurrently using PostgreSQL's reindex SQL command
This article assumes that only the planned resetwal shall be carried out and not any other operation like OS or PG update
in fact, these two group of actions must be mutually excluded. This also implies that an OS start is not intended

*. This document works for changing the size of the WAL segments for single database clusters or multiple replicas in a
replication


Preliminary steps:

0.a Make sure you have entered hostnames and IP Addresses including the following in the /etc/hosts file. 
vip		<vip IP Address>

0.b We set and consider envrionment variables for ease:
Variables:
export PGHOST=vip
export PGPORT=5432
export PGUSER=replicator
export PGPASSWORD='P@$4VV0rd'

0.c I assume that our cluster is composed of 3 nodes and one of the secondary replicas is synchronous and the other one is asynchronous
If you have chosen the quroum-based secondary replicas using the ANY keyword in postgresql.conf synchronous_standby_names directive,
shutting down one of the standby nodes makes the other node the synchronous replica anyways

0.d pg_resetwal official documentation and reference:
https://www.postgresql.org/docs/current/app-pgresetwal.html

0.e Normally, resetting WAL is highly discouraged. This is what you see in pg_resetwal's manual:
"
This function is sometimes needed if these files have become
corrupted. It should be used only as a last resort, when the server will not start due to such corruption
bear in mind that the database might contain inconsistent data due to partially-committed transactions
"
In the official reference, this is what you can find, meaning this binary is perfectly safe for healty database clusters
that have been cleanly shut down.
"
This can be done safely on an otherwise sound database cluster, if none of the dangerous modes mentioned below are used.
"
----------------------------------------------------------------------------------

1. In collaboration with the developers, make sure that the service is suspended so that the data does not change, then perform
a full backup for safety measures. You can ensure data modification prevention in a variety of ways like:
a. stop pg_bouncer or any other proxing intermediary if you want to cut developer access to the database service
sudo systemctl stop pgbouncer.service
b. Quiesce & kill sessions  
ALTER DATABASE payam_db ALLOW_CONNECTIONS false;
# or directly modify the system catalog table:
# UPDATE pg_database SET datallowconn = false WHERE datname = 'payam_db';
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();


2. Full base backup. Sample command:
export PGHOST=vip && export PGPORT=5432 && export PGUSER=replicator && export BACKUP_DIR="/archive/postgresql/pg-local-full-backup/systemd/$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N_ManualBak/)" && export PGPASSWORD='P@$4VV0rd' && \
time /usr/bin/pg_basebackup -h $PGHOST -p $PGPORT -U $PGUSER -w -c fast -D $BACKUP_DIR -Ft -Xs -P

3. Adjust desirable config for all nodes (edit).  
vi /etc/patroni/config.yml
    min_wal_size: 1GB	# Mandatory for resetwal
    max_wal_size: 16GB	# Mandatory for resetwal
    wal_compression: on
    synchronous_standby_names: "FIRST 1 (fmktpayamdb02,fmktpayamdb03)"	# Node 1
    synchronous_standby_names: "FIRST 1 (fmktpayamdb01,fmktpayamdb03)"	# Node 2
    synchronous_standby_names: "FIRST 1 (fmktpayamdb01,fmktpayamdb02)"	# Node 3

Considerations:
Typically, min_wal_size should be at least 2–4 times the wal_segment_size to allow enough space for WAL recycling without frequent resizing.
max_wal_size should be large enough to accommodate spikes in WAL generation (e.g., during large transactions, bulk loads, or checkpoints).
 A common recommendation is 8–64 times the wal_segment_size, depending on workload. For very high-throughput systems (e.g., large batch jobs),
 you may need even higher values
Checkpoint tuning:
Ensure checkpoint_timeout and checkpoint_completion_target are also optimized (e.g., checkpoint_timeout = 15min, checkpoint_completion_target = 0.9).
 Larger max_wal_size allows more time between checkpoints, reducing I/O overhead
Disk Space:
Ensure the disk has enough space for max_wal_size (PostgreSQL may temporarily exceed this under heavy load).
For monitoring after the ultimate changes to check for efficiency of the chosen values:
Monitor pg_stat_bgwriter and WAL directory size to adjust these values further if needed.

Example:
The best practice size of min_wal_size and max_wal_size for wal_seg_size of 256MB is roughly:
min_wal_size = 1GB  (4 segments)	# If the system is write-heavy, consider increasing it to 2GB (8 segments).
max_wal_size = 8GB  (32 segments)  # For moderate workloads
max_wal_size = 16GB (64 segments) # For heavy workloads


4. Stop standbys (checkpoint + stop)  
# Standbys
sudo -iu postgres psql -c 'CHECKPOINT'
sudo systemctl stop patroni.service

5. Wait until the shut down standby nodes become evicted from the cluster completely. You can verify this
by running the following command to see that they are not listed in the nodes list.
sudo patronictl -c /etc/patroni/config.yml list

6. Then do a manual checkpoint on the primary node and stop its service for a clean shutdown.
# primary:
sudo -iu postgres psql -c 'CHECKPOINT'
sudo systemctl stop patroni.service

7. Copy the remaining WAL segments in the primary's pg_wal directory to its archive manually. Their number depends on a variety of parameters.
This is a sample command. Note that we exclude the archive_status directory for copy, and only WAL residuals and history files are intended.
Later extra unneeded WAL remains will be removed by pg_resetwal automatically, and that is why we take a backup of them manually.
# primary:
sudo -iu postgres bash -c "cd /var/lib/postgresql/15/main/pg_wal && find . -maxdepth 1 -mindepth 1 -type f -name '[0-9A-F]*' -exec cp -- {} /archive/postgresql/pg-wal-archive/ \;"



8. On the primary node, execute the pg_resetwal command like below. --wal-segsize will be in Megabytes
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_resetwal -D /var/lib/postgresql/15/main/ --wal-segsize=256


*. On the primary, if you run the reset wal command, a standard output like below appears
root@feasypgdb01:~# sudo -iu postgres /usr/lib/postgresql/15/bin/pg_resetwal -D /var/lib/postgresql/15/main/ --wal-segsize=256
Write-ahead log reset

If you try resetwal on a secondary node, you will get:
root@feasypgdb03:~# sudo -iu postgres /usr/lib/postgresql/15/bin/pg_resetwal -D /var/lib/postgresql/15/main/ --wal-segsize=256
The database server was not shut down cleanly.
Resetting the write-ahead log might cause data to be lost.
If you want to proceed anyway, use -f to force reset.

In some cases for rescue plans we might be forced to bring the cluster up from a secondary node. It shall be safe
if every transaction from the primary has been written to the secondary which is mostly the case especially
synchronous replicas. In such case which you want to certainly do it, you must add a -f flag




9. Confirm wal_segment_size (control + dir)  
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_controldata /var/lib/postgresql/15/main/ | grep -e 'Bytes per WAL segment'
ll -h /var/lib/postgresql/15/main/pg_wal/

10. Start primary using !!!pg_ctlcluster!!!
pg_ctlcluster 15 main start --skip-systemctl-redirect

11. Verify wal_level and wal_segment_size
sudo -iu postgres psql -c 'SHOW wal_segment_size;'
sudo -iu postgres psql -c 'SHOW wal_level;'

*. Take a backup and throw it away (if needed, check wal_level, and if it was minimal, then take the backup. This might happen if have tried to start pg from patroni service by mistake)
export PGHOST=vip && export PGPORT=5432 && export PGUSER=replicator && export BACKUP_DIR="/archive/postgresql/pg-local-full-backup/systemd/$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N_ManualBak/)" && export PGPASSWORD='P@$4VV0rd' && \
time /usr/bin/pg_basebackup -h $PGHOST -p $PGPORT -U $PGUSER -w -c fast -D $BACKUP_DIR -Ft -Xs -P


12. Stop primary using !!!pg_ctlcluster!!!
pg_ctlcluster 15 main stop --skip-systemctl-redirect

13. Start primary using patroni
sudo systemctl start patroni.service

The primary must go to running state in the result of the following command:
sudo patronictl -c /etc/patroni/config.yml list


*. If everything is alright with the primary node, we do the rest of the steps in an ordinary way,
but if due to an incredibly rare reason, for example, a misconfiguration or a human error the primary replica becomes
corrupted, we still have the synchronous replica to treat it like the primary replica and start from pg_resetwal
step above on it again and move forward, like how it was mentioned with -f flag before. 
Or if the entire operation is to abort, we can promote a secondary to new primary
and restart the cluster from its initial state before the maintenance operation. Only, if you want to abort, remember to
revert the config parameters such as "min_wal_size" and "max_wal_size" to their original values



14. Check functionality of the primary thoroughlly, and when !!!OK!!!, remove data dir on each standby and start patroni one by one (serial)
This will internally trigger a backup/restore process from the primary to the subject secondary by Patroni.
rm -rf ~postgres/15/main
sudo systemctl start patroni.service

15. For the restore process to speed up on the secondaries, run a manual CHECKPOINT on the primary for every standby upon starting its
patroni service (It will cause the underlying backup/restore to start immediately) 
* optionally check backup/restore progress using the following on the primary:
psql -h vip -Upostgres -d postgres -tA -c "CHECKPOINT; SELECT ROUND((backup_streamed::numeric/NULLIF(backup_total,0))*100,2) FROM pg_stat_progress_basebackup ORDER BY pid LIMIT 1;"



15. Get Patroni status on the standby node
sudo systemctl status patroni.service


16. Check cluster status to see the standby is added to and is healthy and functional on it. First upon starting standby's patroni service, "Creating Replica" shall appear,
then it must show "streaming"
sudo patronictl -c /etc/patroni/config.yml list

17. Configuration checks (all nodes)
Check whatever configurations you wanted to change: 
clear && sudo -iu postgres /usr/lib/postgresql/15/bin/pg_controldata /var/lib/postgresql/15/main/ | grep -e 'Bytes per WAL segment'
sudo -iu postgres psql --pset=footer=off -c 'SHOW wal_segment_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW synchronous_standby_names;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW min_wal_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW max_wal_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW wal_compression;'

18. Final recovery check for every node (false for primary and true for  standbys)
sudo -iu postgres psql --pset=footer=off -c 'SELECT pg_is_in_recovery()'

19. Nodes synchronous check on primary
sudo -iu postgres psql --pset=footer=off -c "SELECT application_name, sync_state FROM pg_stat_replication where application_name like 'fmktpayamdb%';"
#################################################################

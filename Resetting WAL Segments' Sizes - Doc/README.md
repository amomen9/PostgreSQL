# Resetting WAL Segment Sizes Documentation

This article assumes that only one operation which is the planned **reset wal** task shall be carried out, and not any other operation such as an OS or PostgreSQL (PG) update. In fact, these two groups of actions must be mutually exclusive. This also implies that an OS restart is **not** intended during this maintenance window.

This document applies to changing the size of the WAL (Write-Ahead Log) segments for:
- A single database cluster, or
- A replication setup with multiple replicas (primary and standby nodes).

The objective is to safely adjust the WAL segment size using `pg_resetwal`, while ensuring cluster consistency and recovery capability.

---

## Preliminary Steps

### 0.a Populate `/etc/hosts`
Ensure you have entered hostnames and IP addresses including the following in the `/etc/hosts` file:
```
vip     <vip IP Address>
```
This enables consistent hostname resolution for the virtual IP used by clients and internal scripts.

### 0.b Set Environment Variables
For convenience and consistency during the procedure, set the following environment variables (adjust values as needed):

```shell
export PGHOST=vip
export PGPORT=5432
export PGUSER=replicator
export PGPASSWORD='P@$4VV0rd'
```

These variables allow commands such as `psql` and `pg_basebackup` to run without repeatedly specifying connection options.

### 0.c Replication Topology Assumption
We assume the cluster consists of three nodes:
- One primary
- Two standbys (one synchronous, one asynchronous)

If you have configured quorum-based replication using the `ANY` keyword in the `synchronous_standby_names` directive (for example: `ANY 1 (nodeA,nodeB,nodeC)`), shutting down one standby will cause another eligible node to become the synchronous replica automatically.

### 0.d Official Documentation
`pg_resetwal` reference:
https://www.postgresql.org/docs/current/app-pgresetwal.html

You should carefully review the official documentation before proceeding.

### 0.e Caution About `pg_resetwal`
Normally, resetting WAL is **highly discouraged**. From the manual:
> This function is sometimes needed if these files have become corrupted. It should be used only as a last resort, when the server will not start due to such corruption. Bear in mind that the database might contain inconsistent data due to partially-committed transactions.

However, the official documentation also notes that:
> This can be done safely on an otherwise sound database cluster, if none of the dangerous modes mentioned below are used.

This means the utility is safe for a healthy database cluster that has been **cleanly shut down**, provided you avoid the dangerous modes (such as forcing incorrect LSN values). In this procedure, the intent is controlled WAL segment size adjustment—not recovery from corruption.

---

## Step 1. Quiesce Workload and Perform a Safety Backup

You must coordinate with application developers or operations teams to ensure **no data changes** occur during the maintenance. Options to ensure this:

1. Stop external connection poolers or proxies (e.g., `pgbouncer`):
   ```shell
   sudo systemctl stop pgbouncer.service
   ```

2. Prevent new connections and terminate existing ones for a specific database (example shown for `payam_db`):
   ```shell
   # Disallow new connections
   ALTER DATABASE payam_db ALLOW_CONNECTIONS false;

   # Alternative (direct system catalog modification – less preferred):
   -- UPDATE pg_database SET datallowconn = false WHERE datname = 'payam_db';

   # Terminate existing sessions (excluding the current one)
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE pid <> pg_backend_pid();
   ```

A full physical base backup (Step 2) provides rollback protection in case the procedure must be abandoned.

---

## Step 2. Take a Full Base Backup (Physical)

This ensures you have a safe fallback copy prior to modifying WAL structure.

```shell
export PGHOST=vip && \
export PGPORT=5432 && \
export PGUSER=replicator && \
export BACKUP_DIR="/archive/postgresql/pg-local-full-backup/systemd/$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N_ManualBak/)" && \
export PGPASSWORD='P@$4VV0rd' && \
time /usr/bin/pg_basebackup -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -w -c fast \
  -D "$BACKUP_DIR" -Ft -Xs -P
```

Notes:
- `-Ft` creates a tar-format backup (may produce multiple `.tar` files).
- `-Xs` streams required WAL for a consistent backup.
- This backup is for safety and may be discarded if the procedure completes successfully.

---

## Step 3. Adjust Desired Configuration on All Nodes

Edit Patroni configuration (`/etc/patroni/config.yml`) to ensure `min_wal_size` and `max_wal_size` are appropriate for the new `wal_segment_size` you plan to set via `pg_resetwal`.

Example (per-node differences only in `synchronous_standby_names`):

```yaml
postgresql:
  parameters:
    min_wal_size: 1GB       # Mandatory for resetwal context
    max_wal_size: 16GB      # Mandatory for resetwal context
    wal_compression: on
    synchronous_standby_names: "FIRST 1 (fmktpayamdb02,fmktpayamdb03)"  # Node 1
    # Node 2: synchronous_standby_names: "FIRST 1 (fmktpayamdb01,fmktpayamdb03)"
    # Node 3: synchronous_standby_names: "FIRST 1 (fmktpayamdb01,fmktpayamdb02)"
```

### Considerations

- `min_wal_size` should typically be at least 2–4× the `wal_segment_size` to allow efficient WAL recycling.
- `max_wal_size` must be large enough to absorb workload bursts (bulk loads, long-running transactions, checkpoints).
  - Typical guideline: 8–64 × `wal_segment_size`.
- For very high-throughput systems, even larger values may be required.
- Checkpoint tuning:
  - Example: `checkpoint_timeout = 15min`, `checkpoint_completion_target = 0.9`.
  - Larger `max_wal_size` reduces checkpoint frequency (less I/O churn).
- Disk space:
  - Ensure sufficient space to accommodate up to `max_wal_size`; temporary WAL spikes may exceed it briefly.

### Monitoring After Changes

Monitor:
- `pg_stat_bgwriter`
- WAL directory size growth patterns

### Example Sizing (For `wal_segment_size = 256MB`)
| Workload Type        | Suggested `min_wal_size` | Suggested `max_wal_size` |
|----------------------|---------------------------|---------------------------|
| Moderate             | 1GB (4 segments)          | 8GB (32 segments)         |
| Heavy                | 1GB–2GB (4–8 segments)    | 16GB (64 segments)        |

---

## Step 4. Stop Standby Nodes (Checkpoint First)

Clean shutdown ensures consistent state.

```shell
# On each standby:
sudo -iu postgres psql -c 'CHECKPOINT'
sudo systemctl stop patroni.service
```

---

## Step 5. Wait for Standbys to Evict from Cluster

Verify that the stopped standbys are no longer listed:

```shell
sudo patronictl -c /etc/patroni/config.yml list
```

Proceed only after Patroni no longer shows those nodes as active/healthy.

---

## Step 6. Checkpoint and Stop the Primary

Perform a manual checkpoint and then stop the primary cleanly.

```shell
# On primary:
sudo -iu postgres psql -c 'CHECKPOINT'
sudo systemctl stop patroni.service
```

A clean shutdown is critical before running `pg_resetwal`.

---

## Step 7. Archive Remaining WAL Segment Files (Primary)

Manually copy any remaining WAL segment files for safekeeping before resetting. This is optional but recommended if you want maximum rollback capability.

```shell
# On primary (exclude archive_status; copy only WAL segment and history files)
sudo -iu postgres bash -c "cd /var/lib/postgresql/15/main/pg_wal && \
  find . -maxdepth 1 -mindepth 1 -type f -name '[0-9A-F]*' -exec cp -- {} /archive/postgresql/pg-wal-archive/ \;"
```

Later, `pg_resetwal` may remove unneeded segments; this manual copy preserves them temporarily.

---

## Step 8. Run `pg_resetwal` on the Primary

Reset WAL with the desired new segment size (in megabytes). This alters internal control file metadata and resets WAL sequence.

```shell
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_resetwal -D /var/lib/postgresql/15/main/ --wal-segsize=256
```

### Expected Output (Primary)
```
Write-ahead log reset
```

### If Attempted on a Standby (Example Warning)
```
The database server was not shut down cleanly.
Resetting the write-ahead log might cause data to be lost.
If you want to proceed anyway, use -f to force reset.
```

In rescue scenarios (e.g., promoting a standby due to primary failure), you may need `-f`, but that increases risk—only use it when consistent with recovery strategy and when you are certain of replication state.

---

## Step 9. Confirm `wal_segment_size` (Control File + Directory)

Validate the new segment size in both the control file and filesystem layout.

```shell
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_controldata /var/lib/postgresql/15/main/ | grep -e 'Bytes per WAL segment'
ls -lh /var/lib/postgresql/15/main/pg_wal/
```

The control file value should reflect the new size. Newly generated WAL files will follow the new segment size.

---

## Step 10. Start Primary Using `pg_ctlcluster`

Start PostgreSQL directly—do **not** start Patroni yet, to verify base parameters first.

```shell
pg_ctlcluster 15 main start --skip-systemctl-redirect
```

---

## Step 11. Verify Runtime Settings

Check that PostgreSQL reports the correct WAL-related settings:

```shell
sudo -iu postgres psql -c 'SHOW wal_segment_size;'
sudo -iu postgres psql -c 'SHOW wal_level;'
```

If `wal_level` unexpectedly appears as `minimal`, ensure you did not accidentally bypass Patroni configuration or start with an overridden `postgresql.conf`.

---

## (Optional) Intermediate Safety Base Backup

If needed, take another physical base backup before reintroducing Patroni:

```shell
export PGHOST=vip && \
export PGPORT=5432 && \
export PGUSER=replicator && \
export BACKUP_DIR="/archive/postgresql/pg-local-full-backup/systemd/$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N_ManualBak/)" && \
export PGPASSWORD='P@$4VV0rd' && \
time /usr/bin/pg_basebackup -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -w -c fast \
  -D "$BACKUP_DIR" -Ft -Xs -P
```

This backup can be discarded once confidence is established.

---

## Step 12. Stop the Primary (Direct Instance)

Shut down the manually started instance:

```shell
pg_ctlcluster 15 main stop --skip-systemctl-redirect
```

---

## Step 13. Start Primary Under Patroni

Delegate control back to Patroni now that validation is complete.

```shell
sudo systemctl start patroni.service
```

Check status:
```shell
sudo patronictl -c /etc/patroni/config.yml list
```

The primary should appear in `running` state.

---

## Step 14. Rebuild Standbys (Serially)

After confirming the primary is healthy, rebuild each standby. Remove its old data directory so Patroni triggers a fresh clone.

```shell
# On each standby (one at a time):
rm -rf ~postgres/15/main
sudo systemctl start patroni.service
```

Patroni will automatically perform the internal replication bootstrap.

---

## Step 15. Accelerate Replica Catch-Up (Optional)

Trigger a manual checkpoint on the primary to make required WAL available promptly for each standby:

```shell
psql -h vip -U postgres -d postgres -tA -c "CHECKPOINT; SELECT ROUND((backup_streamed::numeric/NULLIF(backup_total,0))*100,2) FROM pg_stat_progress_basebackup ORDER BY pid LIMIT 1;"
```

The progress query (if any base backup is active) lets you monitor replication bootstrap.

---

## Step 15 (Second Occurrence). Check Patroni Service Status (Standby)

Verify system-level service status on each standby:

```shell
sudo systemctl status patroni.service
```

---

## Step 16. Verify Cluster-Wide Status

Ensure each standby transitions through `Creating Replica` to `streaming`:

```shell
sudo patronictl -c /etc/patroni/config.yml list
```

---

## Step 17. Configuration Validation (All Nodes)

Re-check critical configuration values to confirm they match expectations:

```shell
clear && sudo -iu postgres /usr/lib/postgresql/15/bin/pg_controldata /var/lib/postgresql/15/main/ | grep -e 'Bytes per WAL segment'
sudo -iu postgres psql --pset=footer=off -c 'SHOW wal_segment_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW synchronous_standby_names;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW min_wal_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW max_wal_size;'
sudo -iu postgres psql --pset=footer=off -c 'SHOW wal_compression;'
```

---

## Step 18. Recovery Mode Status (Primary vs Standbys)

Check each node. The primary should return `false`; standbys should return `true`:

```shell
sudo -iu postgres psql --pset=footer=off -c 'SELECT pg_is_in_recovery()'
```

---

## Step 19. Synchronous Replication State (Primary)

Confirm synchronous replication status and which replicas are marked synchronous:

```shell
sudo -iu postgres psql --pset=footer=off -c \
"SELECT application_name, sync_state FROM pg_stat_replication WHERE application_name LIKE 'fmktpayamdb%';"
```

---

## Failure Contingency Notes

- If the primary becomes corrupted due to a rare misconfiguration or operator error, a synchronous standby (if fully caught up) can be used to resume service.
- In a worst-case scenario, promote a healthy standby and revert configuration changes (`min_wal_size`, `max_wal_size`) as needed.
- **Do not** forget to reapply or revert any parameters changed temporarily for the maintenance window.

---

## Summary

This controlled procedure:
1. Quiesces workload.
2. Takes a physical backup for rollback.
3. Adjusts configuration limits.
4. Cleanly shuts down all nodes in a controlled order.
5. Resets WAL segment size safely on the primary.
6. Validates runtime parameters.
7. Rebuilds standbys serially under Patroni.
8. Verifies synchronization and replication health.

By following these steps carefully, you minimize operational risk while successfully resizing WAL segments across a Patroni-managed PostgreSQL replication cluster.

---

## References

- `pg_resetwal` Manual: https://www.postgresql.org/docs/current/app-pgresetwal.html
- Write-Ahead Logging Concepts: https://www.postgresql.org/docs/current/wal-intro.html
- Physical Backup and Replication: https://www.postgresql.org/docs/current/continuous-archiving.html

---
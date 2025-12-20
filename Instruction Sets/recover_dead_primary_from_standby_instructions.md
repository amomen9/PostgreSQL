# Recover a Dead Primary from a Standby (Streaming Replication)

This runbook rebuilds the old primary by taking a fresh base backup from the current primary, then converts the rebuilt node back into a primary.

---

## Assumptions

- You already have a working primary/standby setup.
- The old primary is down or irrecoverable and you want to rebuild it from the standby (now primary).
- You will use `pg_basebackup`.

---

## 1) Install PostgreSQL binaries on the node to rebuild

Install the **same major version** as the current primary.

Important:
- Do **not** initialize a new cluster in the target `PGDATA`.

---

## 2) (Optional) Configure systemd `PGDATA` override

If you want a non-default data directory, configure a systemd drop-in:

```shell
sudo systemctl edit postgresql-13
```

```ini
[Service]
Environment=PGDATA=/data/postgres13/data/
Environment=PGLOG=/var/log/pgsql/
```

```shell
sudo systemctl daemon-reload
```

---

## 3) Allow replication connection from the rebuilding node

On the current primary, add an entry to `pg_hba.conf`:

```conf
host    replication     replicator      <rebuild_node_ip>/32      md5
```

Reload:

```sql
SELECT pg_reload_conf();
```

---

## 4) Take a fresh base backup to the target data directory

On the node you are rebuilding:

```shell
# Replace IP/host, user, port, and path
pg_basebackup -h <primary_ip> -p 5432 -U replicator -D /data/postgres13/data -Fp -Xf -P
```

If you want streaming WAL during the backup:

```shell
pg_basebackup -h <primary_ip> -p 5432 -U replicator -D /data/postgres13/data -P --wal-method=stream
```

Fix ownership:

```shell
sudo chown -R postgres:postgres /data/postgres13
sudo chmod -R 700 /data/postgres13/data
```

---

## 5) Convert to primary (remove standby markers)

If your backup included standby settings (or you used `-R` elsewhere), remove standby signals:

```shell
cd /data/postgres13/data
sudo rm -f postgresql.auto.conf
sudo rm -f standby.signal
sudo rm -f recovery.signal
```

> Which files exist depends on your PostgreSQL version and how the standby was created.

---

## 6) Start PostgreSQL

```shell
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

---

## 7) Validate replication on the primary

On the primary:

```sql
SELECT * FROM pg_stat_replication;
```

You should see a row for the rebuilt node and `state = 'streaming'` when it is connected.

# Install and Configure Pgpool-II on Ubuntu (with PostgreSQL 15/16)

This runbook covers a practical Pgpool-II setup workflow on Ubuntu, including key files (`pgpool.conf`, `pcp.conf`, `pool_hba.conf`) and the commonly-used helper scripts.

> Pgpool-II setups vary significantly (streaming replication vs logical replication, watchdog vs external VIP management, etc.). This document preserves your original flow and adds minimal clarifications.

---

## Prerequisites

- PostgreSQL already installed on all nodes.
- PostgreSQL replication is already working (if you’re using Pgpool-II for failover/HA).
- Passwordless SSH between backend nodes for the Pgpool-II startup user (commonly `postgres`) if you want **online recovery**.

---

## 1) Install required packages

Choose the PostgreSQL major version that matches your cluster.

### PostgreSQL 16

```shell
sudo apt-get update
sudo apt-get -y install pgpool2 libpgpool2 postgresql-16-pgpool2
sudo apt-get -y install postgresql-server-dev-16 postgresql-server-dev-all

# Optional debug symbols
sudo apt-get -y install postgresql-16-pgpool2-dbgsym libpgpool2-dbgsym pgpool2-dbgsym
```

### PostgreSQL 15

```shell
sudo apt-get update
sudo apt-get -y install pgpool2 libpgpool2 postgresql-15-pgpool2
sudo apt-get -y install postgresql-server-dev-15 postgresql-server-dev-all

# Optional debug symbols
sudo apt-get -y install postgresql-15-pgpool2-dbgsym libpgpool2-dbgsym pgpool2-dbgsym
```

---

## 2) Copy template scripts

Template scripts are available here:
- `/usr/share/doc/pgpool2/examples/scripts/`

Copy them to a working directory and remove `.sample` suffixes.

```shell
sudo mkdir -p /data/postgresql/16/scripts
sudo cp /usr/share/doc/pgpool2/examples/scripts/* /data/postgresql/16/scripts/
```

---

## 3) Create `pgpool_node_id` on every node

Create a file named `pgpool_node_id` containing the numeric node ID (example: `0`).

```shell
echo 0 | sudo tee /etc/pgpool2/pgpool_node_id
```

Make sure each node has its own correct ID.

---

## 4) Ensure Pgpool-II status/log files exist

```shell
sudo mkdir -p /var/log/pgpool
sudo touch /var/log/pgpool/pgpool_status
sudo chown -R postgres:postgres /var/log/pgpool
```

`pgpool_status` is important because it persists backend node up/down state across restarts.

---

## 5) Create required PostgreSQL roles

On **every** PostgreSQL node (or at least ensure roles exist consistently), create:
- `repl` (replication)
- `pgpool` (health-check / admin; often needs `pg_monitor` or superuser depending on features)

Inside `psql`:

```sql
-- Prefer SCRAM on modern PostgreSQL
SET password_encryption = 'scram-sha-256';

CREATE ROLE pgpool WITH LOGIN;
CREATE ROLE repl WITH REPLICATION LOGIN;

\password pgpool
\password repl
\password postgres

-- Optional: grant monitoring rights if you don't want pgpool to be superuser
-- GRANT pg_monitor TO pgpool;
```

---

## 6) Authentication files (`.pgpass`, `.pcppass`)

### `.pgpass`

Create `~postgres/.pgpass` (mode `0600`):

```text
*:*:*:postgres:<password>
*:*:*:pgpool:<password>
*:*:*:repl:<password>
```

```shell
sudo -iu postgres chmod 600 ~/.pgpass
```

### `.pcppass`

Create `~postgres/.pcppass` (mode `0600`) for PCP commands:

```text
*:<pcp_port>:pgpool:<password>
```

```shell
sudo -iu postgres chmod 600 ~/.pcppass
```

---

## 7) Customize Pgpool-II scripts

Edit these scripts for your environment (hostnames, paths, ports, users):

- `follow_primary.sh`
- `failover.sh`
- `escalation.sh`
- `recovery_1st_stage`
- `replication_mode_recovery_1st_stage`
- `replication_mode_recovery_2nd_stage`
- `pgpool_remote_start`

Make sure they are executable:

```shell
sudo chmod +x /data/postgresql/16/scripts/*
```

---

## 8) Configure Pgpool-II core files

Main configuration files (Ubuntu typical paths):
- `/etc/pgpool2/pgpool.conf`
- `/etc/pgpool2/pcp.conf`
- `/etc/pgpool2/pool_hba.conf`

### Enable pool HBA

In `pgpool.conf`:

```conf
enable_pool_hba = on
```

### Populate `pcp.conf`

Generate md5 entries:

```shell
# Generates md5 hash lines for pcp.conf
sudo -iu postgres pg_md5 -u pgpool -p
sudo -iu postgres pg_md5 -u postgres -p
sudo -iu postgres pg_md5 -u repl -p
```

Then place output lines into `/etc/pgpool2/pcp.conf`.

Set file permissions appropriately:

```shell
sudo chown postgres:postgres /etc/pgpool2/pcp.conf
sudo chmod 664 /etc/pgpool2/pcp.conf
```

### `pool_passwd` for client auth

If you use `pool_passwd`, uncomment and set its path in `pgpool.conf`.

For SCRAM-style encryption in `pool_passwd`:

```shell
# Creates/updates pool_passwd using the encryption key in .pgpoolkey (recommended)
sudo -iu postgres pg_enc -m -f /etc/pgpool2/pgpool.conf -u postgres -p

# Alternative (md5):
# sudo -iu postgres pg_md5 -m -f /etc/pgpool2/pgpool.conf -u postgres -p
```

---

## 9) Install Pgpool-II extensions in PostgreSQL

These must exist in each database where you plan to use them.
A common approach is to install them in `template1` so new DBs inherit them.

```sql
-- Run on the PRIMARY (or on each DB you need)
CREATE EXTENSION IF NOT EXISTS pgpool_recovery;
CREATE EXTENSION IF NOT EXISTS pgpool_adm;
```

---

## 10) Start and validate Pgpool-II

```shell
sudo systemctl enable pgpool2
sudo systemctl restart pgpool2
sudo systemctl status pgpool2 --no-pager
```

Check backend status via Pgpool port (example `9999`):

```shell
psql -h <vip_or_pgpool_host> -p 9999 -U pgpool -d postgres -c "SHOW pool_nodes"
```

---

## 11) Online recovery and failover (examples)

### Trigger online recovery

```shell
pcp_recovery_node -h <vip_or_pgpool_host> -p 9898 -U pgpool -n 1
```

### Common errors

If you see:
- `ERROR: executing recovery, execution of command failed at "1st stage"`

Most common causes:
- `pgpool_recovery` / `pgpool_adm` extensions missing in `postgres`/`template1` or target DB
- Script files not present where Pgpool expects, or not executable

---

## 12) Optional: systemd override for Pgpool-II startup flags

Some operators set Pgpool-II flags via systemd drop-in (example includes `-n` for foreground).

```shell
sudo systemctl edit pgpool2
```

Example override:

```ini
[Service]
Environment="PGPOOL_OPTS=-D -n"
```

Then:

```shell
sudo systemctl daemon-reload
sudo systemctl restart pgpool2
```

---

## 13) Optional: socket symlinks workaround (if needed)

If Pgpool creates sockets under `/tmp` and clients expect `/var/run/postgresql`, you may need symlinks.

```shell
sudo ln -s /tmp/.s.PGSQL.9999 /var/run/postgresql/.s.PGSQL.9999
sudo ln -s /tmp/.s.PGSQL.9898 /var/run/postgresql/.s.PGSQL.9898
```

Only do this if you actually observe the socket path mismatch.

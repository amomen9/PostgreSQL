# Install and Set Up PostgreSQL 13 on CentOS 8 (PGDG)

This runbook installs PostgreSQL 13 from the official PostgreSQL Yum repository (PGDG) and optionally relocates the `PGDATA` directory.

---

## Prerequisites

- Root or `sudo` access.
- A planned data directory (example: `/data/postgres13/data`) and optional WAL archive directory (example: `/archive`).
- If `SELinux` is enforcing and you move `PGDATA`, you will likely need to update contexts.

---

## 1) Install packages

```shell
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql13-server
```

---

## 2) Create required directories

```shell
sudo mkdir -p /var/log/pgsql /archive /data/postgres13
sudo chown -R postgres:postgres /var/log/pgsql /archive /data/postgres13
```

Optional note:
- If you plan to archive WAL files, you’ll later set `archive_command` to copy into `/archive` (or similar).

---

## 3) Point the service at the new `PGDATA` (recommended: systemd drop-in)

The clean way is a systemd drop-in override.

1. Open the editor:

```shell
sudo systemctl edit postgresql-13
```

2. Add the following, then save/exit:

```ini
[Service]
Environment=PGDATA=/data/postgres13/data/
Environment=PGLOG=/var/log/pgsql/
```

3. Reload systemd:

```shell
sudo systemctl daemon-reload
```

### Alternative (not recommended): edit the unit file

You can find the unit file path:

```shell
systemctl show -p FragmentPath postgresql-13
```

If you edit the unit file directly, you must run:

```shell
sudo systemctl daemon-reload
```

---

## 4) Initialize the cluster

```shell
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
```

If you already initialized in the default location and now want to move it, copy while preserving permissions:

```shell
# Example only: adjust paths based on your environment
sudo cp -a /var/lib/pgsql/13 /data/postgres13/
sudo chown -R postgres:postgres /data/postgres13
```

---

## 5) SELinux (only if needed)

If PostgreSQL fails to start after moving `PGDATA` and SELinux is enforcing, you likely need to relabel contexts.

```shell
# Example: adapt based on your environment
sudo semanage fcontext --add --equal /var/lib/pgsql/13/data /data/postgres13/data
sudo restorecon -rv /data/postgres13/data

sudo chmod -R 700 /data/postgres13/data
sudo chown -R postgres:postgres /data/postgres13
```

To check SELinux mode:

```shell
getenforce
```

Config file location:
- `/etc/selinux/config`

---

## 6) Enable and start PostgreSQL

```shell
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13
```

Verify the active data directory:

```shell
sudo -u postgres psql -c "SHOW data_directory"
```

---

## 7) Network access (optional)

### Firewall

```shell
sudo firewall-cmd --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=5432/tcp
```

### `postgresql.conf`

Set `listen_addresses` (example: listen on all interfaces):

```conf
listen_addresses = '*'
```

### `pg_hba.conf`

Add rules for IPv4 and IPv6 (use `scram-sha-256` instead of `md5` if desired):

```conf
host    all     all     0.0.0.0/0       md5
host    all     all     ::/0            md5
```

Reload config or restart:

```sql
SELECT pg_reload_conf();
```

---

## 8) Create an admin user and database (example)

Inside `psql`:

```sql
CREATE ROLE barman WITH LOGIN SUPERUSER PASSWORD 'change-me';
CREATE DATABASE barman;
GRANT ALL PRIVILEGES ON DATABASE barman TO barman;
```

Or from the shell:

```shell
sudo -iu postgres createuser -s -P barman
```

---

## 9) Optional: add binaries to system PATH

```shell
echo "export PATH=\$PATH:/usr/pgsql-13/bin" | sudo tee -a /etc/profile
```

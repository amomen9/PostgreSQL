# Install and Set Up PostgreSQL on Ubuntu (15/16/17) + Relocate Data Directory

This runbook installs PostgreSQL from the official `apt.postgresql.org` repository and optionally relocates the cluster’s `PGDATA` and related directories.

---

## 1) Add the official PostgreSQL APT repository

```shell
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
```

---

## 2) Install PostgreSQL packages

Choose your major version. Examples include useful contrib/extension packages.

### PostgreSQL 15

```shell
sudo apt install -y \
  postgresql-15 postgresql-doc-15 postgresql-contrib-15 \
  postgresql-15-repack postgresql-15-plpgsql-check postgresql-15-cron \
  postgresql-15-pgaudit postgresql-15-show-plans postgresql-15-plprofiler \
  postgresql-15-preprepare iputils-arping
```

### PostgreSQL 16

```shell
sudo apt install -y \
  postgresql-16 postgresql-doc-16 postgresql-contrib-16 \
  postgresql-16-repack postgresql-16-plpgsql-check postgresql-16-cron \
  postgresql-16-pgaudit postgresql-16-show-plans postgresql-16-plprofiler \
  postgresql-16-preprepare iputils-arping
```

### PostgreSQL 17

```shell
sudo apt install -y \
  postgresql-17 postgresql-doc-17 postgresql-contrib-17 \
  postgresql-17-repack postgresql-17-plpgsql-check postgresql-17-cron \
  postgresql-17-pgaudit postgresql-17-show-plans postgresql-17-plprofiler \
  postgresql-17-preprepare iputils-arping
```

Notes:
- `postgresql-contrib-<ver>` is separate from the core server package.

---

## 3) Stop the default cluster service (if relocating)

If you plan to move the data directory, stop the cluster before copying.

Example for `16-main`:

```shell
sudo systemctl stop postgresql@16-main.service
```

---

## 4) Create target directories

Example layout:
- `/data/postgresql/<ver>/main/data`
- `/data/postgresql/<ver>/main/tablespaces`
- `/data/postgresql/<ver>/main/log`
- `/data/postgresql/<ver>/main/extensions`

```shell
sudo mkdir -p /data/postgresql/16/main/{data,tablespaces,log,extensions}
```

---

## 5) Permissions (example approach)

If you use a DBA group (example: `dbadmins`):

```shell
sudo usermod -aG dbadmins postgres
sudo chown -R postgres:dbadmins /data

# Example permissions: setgid on dirs, group-readable
sudo chmod -R u=rws,g=r,o= /data
sudo chmod -R u+x /data
sudo chmod -R g-x /data
```

Adjust this to your security model.

---

## 6) Copy the data directory to the new location

Example for PostgreSQL 16:

```shell
sudo cp -a /var/lib/postgresql/16/main/. /data/postgresql/16/main/data/
```

If you decide to remove the old data afterwards, do it carefully:

```shell
# DANGER: only do this after you have verified the new cluster starts cleanly
# sudo rm -rf /var/lib/postgresql/16/main
```

---

## 7) Point the cluster at the new directories

On Ubuntu, the server typically starts via `pg_ctlcluster` and uses config under:
- `/etc/postgresql/<ver>/main/postgresql.conf`

Update these settings as needed:

```conf
# Example
data_directory = '/data/postgresql/16/main/data'

# log_directory is typically relative to data_directory unless absolute
log_directory = '/data/postgresql/16/main/log'
```

---

## 8) Start the cluster and validate

```shell
sudo systemctl start postgresql@16-main.service
```

Validate:

```shell
sudo -iu postgres psql -c "SHOW data_directory"
```

---

## 9) Optional extras

### Install `pgagent` (example)

```shell
sudo apt install -y pgagent
sudo -iu postgres psql -c "CREATE EXTENSION IF NOT EXISTS pgagent"
```

---

## Troubleshooting quick checks

```shell
systemctl status postgresql@16-main.service
journalctl -u postgresql@16-main.service -n 200 --no-pager
```

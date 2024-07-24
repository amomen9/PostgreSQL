# PGPOOL (Ubuntu)


**Note:**

1. PostgreSQL major version specified here is 15. However, this manual also complies with most of the pg versions in use, including 13, 14, 15, and 16.
2. pgpool version is 4.5.2
3. There are some glitches for pgpool on Ubuntu, which do not exist on the RHEL. That is because EnterpriseDB is rather Redhat oriented than other Linux distros. I have tried to make up for them and included the solutions in this document. The tests have shown a satisfactory result for myself but the solutions are offered **without a guarantee**.
4. Like many of the watchdog solutions for DBMS HA solutions, the watchdog can be installed on a highly available server, even a separate one. Here we setup the watchdog on all the nodes.
5. The following are the node details used in this documentation:

**Schematic of the sample pgpool replication topology setup (source: [pgpool.net](https://www.pgpool.net/docs/latest/en/html/example-cluster.html)):**

<div style="text-align:center;">
<img align="center" src="image/README/1721627485581.png" alt="1721627485581" style="width:600px;"/>
<br/>
</div>

<br/>
The replication topology is composed of:
<br/>

| row |   Node hostname   | IP Add        | Description            |
| --- | :---------------: | ------------- | ---------------------- |
| 1   |  funleashpgdb01  | 172.23.124.71 | Node 1 (synchronous)   |
| 2   |  funleashpgdb02  | 172.23.124.72 | Node 2 (synchronous)  |
| 3   |  funleashpgdb03  | 172.23.124.73 | Node 3 (asynchronous) |
| 4   | vip (delegate_ip) | 172.23.124.74 | floating virtual IP    |

### Installation:

Add the pg official repository and install PostgreSQL on all the nodes. After adding the PostgreSQL's official repository, you can find pgpool and its related packages in that repository.

#### 1. **Install required packages:**

```shell
sudo apt-get update
sudo apt-get install pgpool2 libpgpool2 postgresql-15-pgpool2
```

postgresql-15-pgpool2 contains extensions for pgpool and is mandatory too. They will be mentioned later. Choose the version of this package which corresponds with your pg major version.

#### 1. **Copy template files:**

copy template script files from the following directory to a specific directory, rename and remove .sample from the end of the files.

```shell
cp /usr/share/doc/pgpool2/examples/scripts/* /data/postgresql/15/main/
```

#### 1. **Create pgpool_node_id file**

create the pgpool_node_id file with the node id (ex 0) below on every node:
Write the following inside shell. The node id starts from 0 for Node 1, 1 for Node 2, and so on.

```
cat << /etc/pgpool2/pgpool_node_id >> EOT
0
EOT
```

#### 2. **Create the backend status file.**

It will be explained later.

```
mkdir -p /var/log/pgpool
touch /var/log/pgpool/pgpool_status		# Backend status file
chown -R postgres /var/log/pgpool		# Log location
```

#### 1. **Assign a password to the user postgres in Linux**

```shell
sudo passwd postgres
```

#### 1. **Create Replication, Health Check, and Recovery users with required privileges on every node.**

```pgsql
-- inside pg engine, create pg users and assign a password to the postgres user in the database cluster engine too, and set up pg_hba.conf file accordingly. A sample of the pg_hba.conf file was given. We take all the passwords to be the same for simplicity.
CREATE USER repl REPLICATION PASSWORD 'Pa$svvord';

-- If you want to show "replication_state" and "replication_sync_state" column in SHOW POOL NODES command result,
-- role pgpool needs to be PostgreSQL super user or in pg_monitor group. This also applies to detach_false_primary feature
-- you can run the following to grant pg_monitor
-- GRANT pg_monitor TO pgpool;
CREATE USER pgpool SUPERUSER PASSWORD 'Pa$svvord';

-- inside psql:
SET password_encryption = 'scram-sha-256';

\password pgpool
\password repl
\password postgres
```

#### 1. **postgresql configuration files: pg_hba.conf**

replication must be enabled for streaming replication and also pg_basebackup to work.

pg_hba.conf sample for every node:

```
local   all             postgres                                peer
local   all             test                                	scram-sha-256
local   all             postgres                                scram-sha-256

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   replication     all                                     scram-sha-256
local   all             all                                     scram-sha-256

# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
host    replication     all             172.23.124.0/24         scram-sha-256
host    all             all             0.0.0.0/0             	scram-sha-256
host    replication     all             0.0.0.0/0             	scram-sha-256
host    all             all             172.23.124.0/24         scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256

# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
```


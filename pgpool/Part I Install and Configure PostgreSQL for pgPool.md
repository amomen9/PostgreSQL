&nbsp;Doc parts:

<ul>
<li>[Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)</li>
<li>[Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)</li>
<li>[Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)</li>
</ul>

# PGPOOL (Ubuntu) Part I

**Note:**

1. PostgreSQL major version specified here is 15. However, this manual also complies with most of the pg versions in use, including 12, 13, 14, 15, 16, and most likely later versions, as well.
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
| 4   | vip (delegate_ip) | 172.23.124.74 | floating Virtual IP    |

### Installation and Configuration of Postgres (Preparing Postgres for pgPool):

#### 1. Install PostgreSQL (every node):

Add the pg official repository and install PostgreSQL on all the nodes. You can see how to install PostgreSQL [here](../PostgreSQL%20in%20General%20%28Single%20Node%20or%20Cluster%29/README.md). 
Do the necessary configurations for PostgreSQL. Make sure that the postgres service is up on the 1st node. The following steps demonstrate how to do that. 

**Very important note!**

In this document, these are the major directories paths. If you need to make alterations, you must change the directories used in this document eveywhere:

**$PGDATA:<br/>**
`/data/postgresql/15/main/data`

**Tablespaces Root Directory:<br/>**
`/data/postgresql/15/main/tablespaces`

**WAL Archive Directory:<br/>**
`/var/postgresql/pg-wal-archive/`

**pgpool .sh script files:<br/>**
`/etc/pgpool2/scripts`

**pgpool script files without extension:<br/>**
`/data/postgresql/15/main/data`

#### 1. Correct the environment variables for Ubuntu (every node):

On Ubuntu, pg environment variables are missing which are needed by scripts execution. They are available in RHEL distributions. So we create them on Ubuntu. For that matter, we add them to the postgres' .bashrc file. The .bashrc and .profile files do not exist, so we do the following:

```shell
sudo cp /etc/skel/{.bashrc,.bash_logout,.profile} ~postgres/
sudo chown -R postgres:postgres ~postgres
```

Then add the required env variables:

```shell
vi ~postgres/.bashrc
```

These are the env entries. Add them to the end of .bashrc file. The `| cut -d '.' -f1` part is to remove the FQDN part from the hostname command output, if any. Note that we have altered the pg data directory to /data/postgresql/15/main/data. This is not mandatory and depends on your preferences:

```shell
declare -x PGDATA=/data/postgresql/15/main/data
declare -x HOSTNAME=$(hostname | cut -d '.' -f1)
declare -x HOME=~
declare -x LOGNAME=$(whoami)
declare -x PWD=~
declare -x USER=$(whoami)
declare -x PGCONNECT_TIMEOUT=1
declare -x HOSTNAME_VAR=$(hostname)
declare -x PGPOOLHOST=$(hostname)
declare -x PGPASSFILE="$(echo ~postgres)/.pgpass"
declare -x PCPPASSFILE="$(echo ~postgres)/.pgpass"
```

After saving the .bashrc file, execute the following to take the modification into effect:

```shell
source ~postgres/.bashrc
```
#### 6. Assign a password to the user postgres in Linux (Every Node)

```shell
sudo passwd postgres
```

#### 7. Create Replication, Health Check, and Recovery users with required privileges on every node.  (Node 1st)

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

#### 8. Create pg password file (.pgpass) (Every Node)

It is used to connect to the database cluster without providing a password from the machine on which we create this file. In fact, the password is taken from this file instead of directly entering it by the user when connecting to the database cluster. We place it under `~postgres`. It shall have the following format:
`hostname:port:database:username:password`
It also accepts * as wildcard. Here is what we fill inside this file:

```conf
*:*:*:postgres:Pa$svvord
*:*:*:pgpool:Pa$svvord
*:*:*:repl:Pa$svvord
```

The .pgpass file must only be accessible by the owner. They must have 0600 mode. Note that we have defined the PGPASSFILE env variable before too to point to the location that I mentioned. But even if we did not, the default location would be ~postgres/.pgpass

```shell
chmod 0600 ~postgres/.pgpass
```

#### 12. postgresql configuration files: pg_hba.conf (Every Node)

replication must be enabled for streaming replication and also pg_basebackup to work.

pg_hba.conf sample for every node:

```conf
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

#### 13. postgresql configuration files: postgresql.conf (Every Node)

Here, we only mention and change the parameters which are necessary for setting up this pgpool cluster. Note that these parameter configurations are similar to other HA and clustering solutions. We choose streaming physical replication method. Some configurations are default, but they are noted anyways for their importance.

According to our backup conventions, we choose the WAL archive location to be the following and set archive_command and restore_command accordingly.

The PGDATA (pg data directory) has also been changed, thus we have to specify this in postgresql.conf file too in the following directive.

`data_directory = '/data/postgresql/15/main/data'`

postgresql.conf sample for every node:

```conf
#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------
data_directory = '/data/postgresql/15/main/data'

#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------
listen_addresses = '*'

#------------------------------------------------------------------------------
# WRITE-AHEAD LOG
#------------------------------------------------------------------------------
wal_level = replica
synchronous_commit = on

archive_mode = on
archive_command = 'test ! -f /var/postgresql/pg-wal-archive/%f && cp %p /var/postgresql/pg-wal-archive/%f'
restore_command = 'cp /var/postgresql/pg-wal-archive/%f %p'

#------------------------------------------------------------------------------
# REPLICATION
#------------------------------------------------------------------------------
synchronous_standby_names = 'ANY 2 (funleashpgdb01,funleashpgdb02,funleashpgdb03)'

promote_trigger_file = 'standalone.signal'
hot_standby = on
```


#### 2.  Stop postgres' service and remove postgres' data directory contents (Node 2nd and 3rd only):

**Important Note!**
Only remove the contents of the data directory on the 2nd and 3rd nodes.

After installing and configuring postgres, remove postgres' data directory contents on the second and third nodes (be carefull not to delete the data directory itself), because at some point forward we are going to recover the second and third nodes from the first node using pgpool's online recovery process completely and at such point the data directory must be clean:

```shell
systemctl stop postgresql@15-main.service	# for pg version '15', and cluster name 'main' which is the default cluster.

rm -rf $PGDATA/*
```



# [Next: Part II, Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)

&nbsp;Doc parts:


* [Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)
* [Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)
* [Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)
* [Part IV: fix some glitches for Ubuntu](./Part%20IV%20fix%20some%20glitches%20for%20Ubuntu.md)
* [Part V: pgpool command, pcp, pgpool admin commands.md ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)
* [Part VI: Finish up, simulations, tests, notes.md ](./Part%20VI%20Finish%20up%2C%20simulations%2C%20tests%2C%20notes.md)


# PGPOOL (Ubuntu) Part I
**Install and Configure PostgreSQL for pgPool**

**Note:**

1. PostgreSQL major version specified here is 15. However, this manual also complies with most of the pg versions in use, including 12, 13, 14, 15, 16, and most likely later versions, as well.
2. pgpool version is 4.5.2
3. There are some glitches for pgpool on Ubuntu, which do not exist on the RHEL. That is because EnterpriseDB is rather Red hat oriented than other Linux distros. I have tried to make up for them and included the solutions in this document. The tests have shown a satisfactory result for myself but the solutions are offered **without a guarantee**.
4. Like many of the watchdog solutions for DBMS HA solutions, the watchdog can be installed on a highly available set of servers, even a separate one. Here we setup the watchdog on all the backend (pg) nodes themselves.
5. Note that many of the commands that have "sudo" at their beginning in this document do not have to have this command if they run under postgres user. However, I have assumed that
 these commands are being executed under another sudoer user.
6. The scripts and configuration files are both embedded in this doc and included in the git repository.
7. Most of the steps in this document are sequential and the later steps depend on the earlier steps. So, follow the steps in order.
8. Not mentioning the non-mandatory command-line arguments means their default values.
9. Study the scripts thoroughly and try to understand them. Some explanatory comments have been added to the scripts but you should understand all of their contents.
10. The PostgreSQL database cluster can also initially be created from a backup rather than a raw database cluster.
11. In my opinion, this document also includes some practical Linux learning which might be useful for you.
12. The following are the node details used in this documentation:

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

1. set hostnames and IP addresses if necessary (Every Node):

* set hostnames:
```shell
sudo hostnamectl set-hostname <hostname>
```

* set static IP addresses either using DHCP or directly giving the machines static IP addresses.

* Add hostnames and IPs to the `/etc/hosts` file for local hostname resolution (Every Node):

```hosts
172.23.124.71 funleashpgdb01
172.23.124.72 funleashpgdb02
172.23.124.73 funleashpgdb03
172.23.124.74 vip

```

#### Firewall (Every Node)

Either disable the firewall or allow the needed incoming TCP ports for it.
The needed TCP ports (If you are using the defaults) are:
PostgreSQL:
5432/tcp
pgpool:
9999/tcp, 9000/tcp, 9694/tcp

These ports must be open in both local machine and infrastructure/cloud firewall for the required sources.

### Installation and Configuration of PostgreSQL (Preparing PostgreSQL for pgPool):

#### 1. Install PostgreSQL (Every Node):

Add the pg official repository and install PostgreSQL on all the nodes. You can see how to install PostgreSQL in the "PostgreSQL in General (Single Node or Cluster)/README.md" of this repository.
Do the necessary configurations for PostgreSQL. Make sure that the postgres service is up on the 1st node. The following steps demonstrate how to do that.

**Very important note!**

In this document, these are the major directories paths.
 All these directories must exist and the postgres user must have full access to them.
 If you need to make alterations, you must change the directories used in this document everywhere:

**$PGDATA:**

`/data/postgresql/15/main/data`

**Tablespaces Root Directory:**

`/data/postgresql/15/main/tablespaces`

**WAL Archive Directory:**

`/var/postgresql/pg-wal-archive/`

**pgpool .sh script files:**

`/etc/pgpool2/scripts`

**pgpool script files without extension:**

`/data/postgresql/15/main/data`

**Maintenance scripts and glitch fixing scripts**

`/data/postgresql/scripts`

#### 1. Correct the environment variables for Ubuntu (Skip for Red Hat) (Every Node):

* For a comprehensive list of pg environment variables, refer to the following reference:

[https://www.postgresql.org/docs/current/libpq-envars.html](https://www.postgresql.org/docs/current/libpq-envars.html)

On Ubuntu, there is a shortcoming in which the pg environment variables are missing by default
 that are needed by the scripts execution (either automatically or using PCP commands). They are
 available in RHEL distributions. So we create them on Ubuntu manually. There might be several ways
 available. But we do one of the most convenient below:

* **Steps:**

We add them to the global bashrc file `/etc/bash.bashrc` to make the env variables available for every shell.
 We do the following:

1. edit the file:

```shell
sudo vi /etc/bash.bashrc
```

Then add the required env variables.

These are a sample of the env entries for this file. Add them to the end of bash.bashrc file.
 The `| cut -d '.' -f1` part is to remove the FQDN part from the hostname command output,
 if any. Note that we have altered the pg data directory to /data/postgresql/15/main/data.
 This is not mandatory and depends on your preferences. If the matter is to put pg data
 on another storage, you can do that using a mount point on both /data/postgresql/15/main/data
 and the default ~postgres/15/main directory:

```shell
# env vars:
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
declare -x PCPPASSFILE="$(echo ~postgres)/.pcppass"
declare -x PGPOOLKEYFILE="$(echo ~postgres)/.pgpoolkey"
```

2. After saving the file, the new shells that are instantiated will have the environment variables. **However**,
 the already instantiated shells will not have them. For the modification to take effect for all the shells,
 a reboot is required.

```shell
sudo reboot -i
```

* For the record, you could follow some other approaches, For example, creating a ".sh" file and executing it in the service
 file using ExecStartPre, populating the /etc/postgresql/<pg maj version>/<pg cluster name>/environment with static entries,'
 using EnvironmentFile directive in systemd service, etc.


#### 6. (**Only with pgpool**) Assign a password to the user postgres in Linux (Every Node)

The `postgres` user does not come with a password after installing PostgreSQL by default for security reasons. 
So, **it is not generally recommended to assign it a password and you should avoid it except for the pgpool case.**

Let the password for postgres user be the same on all the nodes for simplicity.
```shell
sudo passwd postgres
```

| Hardening:<br/><br/>Also deny postgres user from logging in using ssh connection like below. <br/>However, you should do this at the end of setting up the pgpool cluster for your convenience, <br/>because you are going to copy postgres and pgpool files to the machines using ssh. <br/>If you do this using the postgres user, you will not be forced to change the ownership <br/>of those files to postgres. This way you will spare yourself a big turmoil. |
| :-------:|

----
1. Open the SSH configuration file
```shell
sudo nano /etc/ssh/sshd_config
```

2. Add the DenyUsers directive
```shell
DenyUsers postgres
```

3. Save and close the file.

4. Restart the SSH service to apply the changes
```shell
sudo systemctl restart ssh
```
----

#### 7. Create Replication, Health Check, and Recovery users with required privileges on Every Node.  (Node 1st)

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

It is used to connect to the database cluster without providing a password from the machine
 on which we create this file. In fact, the password is taken from this file instead of
 directly entering it by the user when connecting to the database cluster. We place it under
 `~postgres`. We also use plain passwords. It shall have the following format:
`hostname:port:database:username:password`
It also accepts * as wildcard. Here is what we fill inside this file:

```shell
sudo -u postgres vi ~postgres/.pgpass
```

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

pg_hba.conf sample for Every Node:

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

Before modifying this file, we create our custom directory for the full backups and WAL archive destination
 for archive and restore commands (These are my choices for these destinations and can be chosen to be somewhere else):

```shell
sudo mkdir -p /var/postgresql/{pg-wal-archive,pg-local-full-backup}
sudo chown -R postgres:postgres /var/postgresql
```

postgresql.conf sample for Every Node. This is a sample, but the nodes should
 have a configuration like this and these directives anyways:

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

After installing and configuring postgres, remove postgres' data directory contents on the second and third nodes (be careful not to delete the data directory itself), because at some point forward we are going to recover the second and third nodes from the first node using pgpool's online recovery process completely and at such point the data directory must be clean:

```shell
pg_ctlcluster 15 main stop -m immediate	# for pg version '15', and cluster name 'main' which is the default cluster.

rm -rf $PGDATA/*
```

or

```shell
sudo systemctl stop postgresql@15-main.service	# for pg version '15', and cluster name 'main' which is the default cluster.

rm -rf $PGDATA/*
```

The first one can be executed by using the postgres user without the sudo privilege.

# [Next: Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)

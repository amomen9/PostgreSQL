&nbsp;Doc parts:


* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge & Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)


# Part I: Setup PostgreSQL, Patroni, and Watchdog
**Install and Configure PostgreSQL**

**Note:**

1. PostgreSQL major version specified here is 17. However, this manual also complies with most of the pg versions in use, including 12, 13, 14, 15, 16, and most likely later versions, as well.
4. Like many of the watchdog solutions for DBMS HA solutions, the watchdog can be installed on a highly available set of servers, even a separate one. Here we setup the watchdog on all the backend (pg) nodes themselves.
6. The scripts and configuration files are both embedded in this doc and included in the git repository.
7. Most of the steps in this document are sequential and the later steps depend on the earlier steps. So, follow the steps in order.
8. Not mentioning the non-mandatory command-line arguments means their default values.
10. The PostgreSQL database cluster can also initially be created from a backup rather than a raw database cluster.
12. The following are the node details used in this documentation:

---

<br/>
The replication topology is composed of:
<br/>
<br/>

| row |   Node hostname   | IP Add        | Description            |
| --- | :---------------: | ------------- | ---------------------- |
| 1   |  funleashpgdb01  | 172.23.124.71 | Node 1 (synchronous)   |
| 2   |  funleashpgdb02  | 172.23.124.72 | Node 2 (synchronous)  |
| 3   |  funleashpgdb03  | 172.23.124.73 | Node 3 (asynchronous) |
| 4   |      VIP       | 172.23.124.74   | floating Virtual IP    |

One of the standby nodes is synchronous and the other one is asynchronous in quorum mode (the
 word "ANY 1" is used in the "synchronous_standby_names" directive of the postgresql.conf file)


0. **Disk layouts (Every Node):**

For the database clusters with large amount of data, I used to move the data directory to somewhere else.
 For example, /data/postgresql/13/main or whatever. However, later on I came to the conclusion that the best
 way is, at least regarding PostgreSQL, to keep everything in its default location and instead define mount
 points in the default locations and attach separate disks to those mount points. For example, prior to the
 installation of PostgreSQL, we can consider the following mount points. We actually do the first 3 of the following
 4 this in this document:
 
-. `/var/lib/postgresql/`

-. `/var/log/`

-. `/var/lib/etcd`
 
-. `/var/lib/postgresql/17/main/pg_tblspc/`

Here is a sample figure of the disk layout:

![1.png](images/1.png)

If we actually set exclusive mount point for PostgreSQL or other services specific directories,
 such directories have to exist prior to these services installation. Upon installation of these
 services, their particular users will also be created. For PostgreSQL, it is postgres, and for
 etcd, it is etcd. Point is, right after the installtion which estabilishes these users, we run
 the following:
 
```shell
chown -R postgres:postgres /var/lib/postgresql
chown -R etcd:etcd /var/lib/etcd
```

1. set hostnames and IP addresses if necessary (Every Node):

* 1. set hostnames:
```shell
sudo hostnamectl set-hostname <hostname>
```

* 2. set static IP addresses either using DHCP or directly giving the machines static IP addresses.

* 3. Add hostnames and IPs to the `/etc/hosts` file for local hostname resolution (Every Node):

```hosts
172.23.124.71 funleashpgdb01
172.23.124.72 funleashpgdb02
172.23.124.73 funleashpgdb03
172.23.124.74 vip

```

#### 2. Firewall (Every Node)

Either disable the firewall or allow the needed incoming TCP ports for it.
The needed TCP ports (If you are using the defaults) are:
PostgreSQL:
5432/tcp
etcd:
2380/tcp, 2379/tcp

These ports must be open in both local machine and infrastructure/cloud firewall for the required sources.

To disable firewall entirely:

```shell
# Disable service
systemctl disable --now ufw
# Mask it so that it will start again
systemctl mask ufw
```

#### 3. Create required directories (Every Node):

Directories to create:

```shell
mkdir -p /var/log/patroni
chown -R postgres:postgres /var/log/patroni

# For local WAL archiving (using archive_command):
mkdir -p /archive/postgresql/pg-wal-archive/
# For local full backups:
mkdir -p /archive/postgresql/pg-local-full-backup/systemd/
chown -R postgres:postgres /archive/postgresql
```

#### 4. Install PostgreSQL (Every Node):

Install PostgreSQL and mask its service

```shell
sudo apt install -y postgresql-17 postgresql-17-repack postgresql-17-plpgsql-check \
postgresql-17-cron postgresql-17-pgaudit postgresql-17-show-plans postgresql-doc-17 \
postgresql-contrib-17 postgresql-17-plprofiler plprofiler postgresql-17-preprepare iputils-arping

systemctl disable --now postgresql.service postgresql@17-main.service
systemctl mask postgresql.service postgresql@17-main.service
```

#### 5. Install Patroni (Every Node):

Install Patroni and Stop and disable it if it's running

```shell
apt install -y patroni
systemctl disable --now patroni
```

#### 6. Put patroni config files in place (config.yml disable dcs.yml) (Every Node)

```shell
# We are not needing dcs.yml in our implementation
mv /etc/patroni/dcs.yml /etc/patroni/dcs.yml.bak
chown -R postgres:postgres /etc/patroni

```

#### 7. Modify the patroni's configuration file (Every Node):

Reference:

[YAML Configuration Settings, Patroni Documentation](https://patroni.readthedocs.io/en/latest/yaml_configuration.html)

```shell
vi /etc/patroni/config.yml
```

The patroni yml configuration file should be something like the following on every node. Just note the <ins>node-specific
 configurations</ins> in this file

<details>
<summary>(click to expand) The complete default <b>pgpool.conf</b> file with added explanations:</summary>

```conf
scope: "15-main"
namespace: "maunleashdb"
name: maunleash01

log:
  traceback_level: INFO
  level: INFO
  dir: /var/log/patroni/
  file_num: 6
  file_size: 25165824
  mode: 0644



# @DCS_CONFIG@

restapi:
  listen: 172.23.124.71:8008
  connect_address: 172.23.124.71:8008
#  certfile: /etc/ssl/certs/ssl-cert-snakeoil.pem
#  keyfile: /etc/ssl/private/ssl-cert-snakeoil.key
#  authentication:
#    username: username
#    password: password

# ctl:
#   insecure: false # Allow connections to SSL sites without certs
#   certfile: /etc/ssl/certs/ssl-cert-snakeoil.pem
#   cacert: /etc/ssl/certs/ssl-cacert-snakeoil.pem

etcd3:
  protocol: http
  hosts: 172.23.124.71:2379,172.23.124.72:2379,172.23.124.73:2379


bootstrap:

  # Custom bootstrap method
  # The options --scope= and --datadir= are passed to the custom script by
  # patroni and passed on to pg_createcluster by pg_createcluster_patroni
  method: pg_createcluster
  pg_createcluster:
    command: /usr/share/patroni/pg_createcluster_patroni

  # This section will be written into /<namespace>/<scope>/config after
  # initializing a new cluster and all other cluster members will use it as a
  # `global configuration`
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    check_timeline: true
#    master_start_timeout: 300
#    synchronous_mode: false
#    standby_cluster:
#      host: 127.0.0.1
#      port: 1111
#      primary_slot_name: patroni
    postgresql:
      use_pg_rewind: true
      remove_data_directory_on_rewind_failure: true
      remove_data_directory_on_diverged_timelines: true
      use_slots: true
      # The following parameters are given as command line options
      # overriding the settings in postgresql.conf.
#      parameters:
##        wal_level: hot_standby
##        hot_standby: "on"
##        wal_keep_segments: 8
##        max_wal_senders: 10
##        max_replication_slots: 10
##        max_worker_processes = 8
##        wal_log_hints: "on"
##        track_commit_timestamp = "off"
##      recovery_conf:
##        restore_command: cp ../wal_archive/%f %p
      # Set pg_hba.conf to the following values after bootstrapping or cloning.
      # If you want to allow regular connections from the local network, or
      # want to use pg_rewind, you need to uncomment the fourth entry.
      pg_hba:
#      - local   all             all                                     peer
#      - host    all             all             127.0.0.1/32            md5
#      - host    all             all             ::1/128                 md5
##      - host    all             all             @NETWORK@               md5
#      - local   replication     all                                     peer
#      - host    replication     all             127.0.0.1/32            md5
#      - host    replication     all             ::1/128                 md5
#      - host    replication     all             @NETWORK@               md5
      - local replication replicator trust
      - local all all peer
      - host all all 127.0.0.1/32 trust
      - host all all ::1/128 trust
      - host replication all 0.0.0.0/0 md5
      - host all all 0.0.0.0/0 md5
        

#  # Some possibly desired options for 'initdb'. Note: It needs to be a list
#  # (some options need values, others are # switches)
#  initdb:
#  - encoding: UTF8
#  - data-checksums

#  # Additional script to be launched after initial cluster creation (will be
#  # passed the connection URL as parameter)
#  post_init: /usr/local/bin/setup_cluster.sh

#  # Additional users to be created after initializing the cluster
#  users:
#    foo:
#      password: bar
#      options:
#        - createrole
#        - createdb

postgresql:
  # Custom clone method
  # The options --scope= and --datadir= are passed to the custom script by
  # patroni and passed on to pg_createcluster by pg_clonecluster_patroni
  create_replica_method:
    - pg_clonecluster
  pg_clonecluster:
    command: /usr/share/patroni/pg_clonecluster_patroni

  # Listen to all interfaces by default, this makes vip-manager work
  # out-of-the-box without having to set net.ipv4.ip_nonlocal_bind or similar.
  # If you prefer to only listen on some interfaces, edit the below:
#  listen: "@HOSTIP@@LISTEN_VIP@,127.0.0.1:@PORT@"
  listen: "*:5432"
  connect_address: 172.23.124.71:5432
  use_unix_socket: true
  ## Default Debian/Ubuntu directory layout
  # data_dir: @DATADIR_BASE@/@VERSION@/@CLUSTER@
  # bin_dir: /usr/lib/postgresql/@VERSION@/bin
  # config_dir: /etc/postgresql/@VERSION@/@CLUSTER@
  # pgpass: /var/lib/postgresql/@VERSION@-@CLUSTER@.pgpass
  # Modified directory layout:
  data_dir: /var/lib/postgresql/15/main/
  bin_dir: /usr/lib/postgresql/15/bin
  config_dir: /etc/postgresql/15/main
  pgpass: /var/lib/postgresql/.pgpass
  
  authentication:
    replication:
      username: "replicator"
      password: "p@ssvv0rcl"
    # A superuser role is required in order for Patroni to manage the local
    # Postgres instance.  If the option `use_unix_socket' is set to `true',
    # then specifying an empty password results in no md5 password for the
    # superuser being set and sockets being used for authentication. The
    # `password:' line is nevertheless required.  Note that pg_rewind will not
    # work if no md5 password is set unless a rewind user is configured, see
    # below.
    superuser:
      username: "postgres"
      password: "p@ssvv0rcl"
    # A rewind role can be specified in order for Patroni to use on PostgreSQL
    # 11 or later for pg_rewind, i.e. rewinding a former primary after failover
    # without having to re-clone it. Patroni will assign this user the
    # necessary permissions (that only exist from PostgreSQL)
#    rewind:
#      username: "rewind"
#      password: "rewind-pass"

  parameters:
    # data dir location
    data_directory: '/var/lib/postgresql/15/main/'
    # network params:
    listen_addresses: "*"
    unix_socket_directories: '/var/run/postgresql/'
    # Emulate default Debian/Ubuntu logging
    logging_collector: 'on'
    log_directory: '/var/log/postgresql/'
    log_filename: 'postgresql-15-main-%A.log'
    #log_file_mode: 0600
    log_rotation_age: 1d
    #log_rotation_size: 1024MB
    log_truncate_on_rotation: on
    #transaction log params
    synchronous_commit: "on"
    archive_mode: "on"
    archive_command: "test ! -f /archive/postgresql/pg-wal-archive/%f && cp %p /archive/postgresql/pg-wal-archive/%f"
    wal_keep_segments: 8
    max_wal_senders: 10
    max_replication_slots: 10
    max_worker_processes: 8
    wal_log_hints: "off"
    track_commit_timestamp: "on"
    # synchornization or cluster params:
    synchronous_standby_names: "ANY 1 (maunleash01,maunleash02,maunleash03)"
    # perf params:
    max_connections: 300
    #
    # RedgateMonitor associated params:
    #
    #########################################################################################
    #                       Redgate Monitor Parameters                                      #
    #########################################################################################
    #
    log_destination: 'stderr,csvlog'
    shared_preload_libraries: 'pg_stat_statements, auto_explain' # (change requires restart)
    track_io_timing: on  # We recommend setting `track_io_timing` to 'on' to give more a more detailed view of queries' IO performance.
    #
    auto_explain.log_format: json             # this must be set to json as shown
    auto_explain.log_level: LOG               # this must be set to LOG as shown
    auto_explain.log_verbose: true            # records more detailed query plan information
    auto_explain.log_analyze: true            # causes timing for each node to be recorded
    auto_explain.log_buffers: true            # record buffer usage statistics
    auto_explain.log_wal: true                # record WAL performance statistics (PostgreSQL >= 13 only)
    auto_explain.log_timing: true             # record per-node timing
    auto_explain.log_triggers: true           # record trigger statistics
    auto_explain.sample_rate: 0.01            # record plans for only 1% of queries
    auto_explain.log_min_duration: 30000      # 30000 ms: 30 seconds
    auto_explain.log_nested_statements: true  # records the plan for any nested statement invoked by a function call
    log_file_mode: 0640
    #
    ####################### End RedgateMonitor associated params ############################
    #
    # Other Parameteres

```

</details>

#### 8. Install etcd (Every Node)

Install etcd and stop and disable it if it's running.

```shell
apt install -y etcd
systemctl disable --now etcd
```

#### 9. Make the etcd API version 3 global (Every Node)

Make it global by putting it inside /etc/profile

```shell
vi /etc/profile
export ETCDCTL_API=3
```

Then ake it effective for the current session too:

```shell
source /etc/profile
```

#### 10. Edit the /etc/default/etcd file (Every Node)

Reference:

[https://etcd.io/docs/v3.4/op-guide/configuration/](https://etcd.io/docs/v3.4/op-guide/configuration/)

Edit it like below:

```shell
ETCD_NAME=n1
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://172.23.124.71:2380"
ETCD_LISTEN_CLIENT_URLS="http://172.23.124.71:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.23.124.71:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://172.23.124.71:2379"
ETCD_INITIAL_CLUSTER="n1=http://172.23.124.71:2380,n2=http://172.23.124.72:2380,n3=http://172.23.124.73:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-pg"
ETCD_AUTO_COMPACTION_RETENTION=168
# 7 days
ETCD_AUTO_COMPACTION_MODE=periodic
ETCD_MAX_SNAPSHOTS=5
ETCD_MAX_WALS=5

```

#### 11. Create the necessary PostgreSQL users (First Node Only)

Make sure the postgresql database cluster is functional on the first node, we disabled it
 upon installation, thus we need to start it manually. Then connect to it and alter or
 create necessary users and their permissions. Then check the changes:
 
```shell
pg_ctlcluster 17 main start
``` 

```PL/PGSQL
alter user postgres password 'p@ssvv0rcl';
create user replicator replication password 'p@ssvv0rcl';
select * from pg_user;
```

#### 12. Delete data directory contents (2nd and 3rd Nodes only)

Delete data directory contents on the 2nd and 3rd nodes only

```shell
rm -rf /var/lib/postgresql/17/main/*
```

#### 13. Enable and start etcd service (Every Node)

Start <ins>from the first node</ins>, then go on with other nodes, as well.

```shell
systemctl enable --now etcd
```

#### 14. Enable and start patroni service (First Node Only)

We want to start patroni for the first time. Thus, we want
 to make sure that postgresql is not running. postgresql  We do these by executing the following commands



# [Next: Part II: Logs Purge & Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)

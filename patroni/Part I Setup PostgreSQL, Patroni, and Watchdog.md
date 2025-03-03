&nbsp;Doc parts:

* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)
* [Part III: Evict/Add node from/to the cluster ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)

# Part I: Setup PostgreSQL, Patroni, and Watchdog

**Install and Configure PostgreSQL**

**Note:**

1. PostgreSQL major version specified here is 17. However, this manual also complies with most of the pg versions in use, including 12, 13, 14, 15, 16, and most likely later versions, as well.
2. Like many of the watchdog solutions for DBMS HA solutions, the watchdog can be installed on a highly available set of servers, even a separate one. Here we setup the watchdog on all the backend (pg) nodes themselves.
3. The scripts and configuration files are both embedded in this doc and included in the git repository.
4. Most of the steps in this document are sequential and the later steps depend on the earlier steps. So, follow the steps in order.
5. Not mentioning the non-mandatory command-line arguments means their default values.
6. The PostgreSQL database cluster can also initially be created from a backup rather than a raw database cluster.
7. The following are the node details used in this documentation:

---

<br/>
The replication topology is composed of:
<br/>
<br/>

| row | Node hostname | IP Add        | Description            |
| --- | :------------: | ------------- | ---------------------- |
| 1   | funleashpgdb01 | 172.23.124.71 | Node 1 (synchronous)   |
| 2   | funleashpgdb02 | 172.23.124.72 | Node 2 (synchronous)  |
| 3   | funleashpgdb03 | 172.23.124.73 | Node 3 (asynchronous) |
| 4   |      VIP      | 172.23.124.74 | floating Virtual IP    |

One of the standby nodes is synchronous and the other one is asynchronous in quorum mode (the
 word "ANY 1" is used in the "synchronous_standby_names" directive of the postgresql.conf file)

0. **Disk layouts (Every Node):**

For the database clusters with large amount of data, I used to move the data directory to somewhere else.
 For example, /data/postgresql/13/main or whatever. However, later on I came to the conclusion that the best
 way is, at least regarding PostgreSQL, to keep everything in its default location and instead define mount
 points in the default locations and attach separate disks to those mount points. For example, prior to the
 installation of PostgreSQL, we can consider the following mount points. We actually do the first 3 of the following
 4 this in this document:

- `/var/lib/postgresql/`
- `/var/log/`
- `/var/lib/etcd`
- `/var/lib/postgresql/17/main/pg_tblspc/`

Here is a sample figure of the disk layout:

![1.png](image/PartISetupPostgreSQL,Patroni,andWatchdog/1.png)

If we actually set exclusive mount point for PostgreSQL or other services specific directories,
 such directories have to exist prior to these services installation. Upon installation of these
 services, their particular users will also be created. For PostgreSQL, it is postgres, and for
 etcd, it is etcd. Point is, right after the installtion which estabilishes these users, we change
 the ownership of `/var/lib/postgresql` and `/var/lib/etcd` to postgres and etcd respectively.


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
sudo systemctl disable --now ufw
# Mask it so that it will start again
sudo systemctl mask ufw
```

#### 3. Install PostgreSQL (Every Node):

First install the PostgreSQL's repository from its official website, [https://postgresql.org](https://postgresql.org).

Install PostgreSQL and mask its service

```shell
sudo apt update
sudo apt install -y postgresql-17 postgresql-17-repack postgresql-17-plpgsql-check \
postgresql-17-cron postgresql-17-pgaudit postgresql-17-show-plans postgresql-doc-17 \
postgresql-contrib-17 postgresql-17-plprofiler plprofiler postgresql-17-preprepare iputils-arping


# postgresql-17: This is the main PostgreSQL 17 database server package, which includes the core database server software.
# postgresql-17-repack: A utility to reorganize tables and indexes without significant downtime, helping to optimize the database by reducing bloat.
# postgresql-17-plpgsql-check: A package that provides a plpgsql_lint function to check the syntax and structure of PL/pgSQL functions.
# postgresql-17-cron: Adds cron-like scheduling capabilities to PostgreSQL, allowing jobs to be scheduled and run inside the database.
# postgresql-17-pgaudit: An extension that provides detailed session and object audit logging via the standard logging facility provided by PostgreSQL.
# postgresql-17-show-plans: Captures execution plans of SQL statements automatically for monitoring purposes.
# postgresql-doc-17: Documentation for PostgreSQL 17, including guides and manuals.
# postgresql-contrib-17: A collection of additional extensions and tools contributed by the PostgreSQL community, enhancing the database's functionality.
# postgresql-17-plprofiler: Provides profiling tools to analyze the performance of PL/pgSQL functions within PostgreSQL.
# plprofiler: A related tool to postgresql-17-plprofiler, used to visualize and analyze PL/pgSQL profiling data.
# postgresql-17-preprepare: An extension for pre-parsing SQL statements to improve performance by reducing the parsing overhead.
# iputils-arping: A network utility for sending ARP requests to discover or ping a host on the same network.


sudo systemctl disable --now postgresql.service postgresql@17-main.service
sudo systemctl mask postgresql.service postgresql@17-main.service
```

Now, as said in the section `0`, we change the ownership of `/var/lib/postgresql`
 to postgres.

```shell
sudo chown -R postgres:postgres /var/lib/postgresql
```

#### 4. Create required directories (Every Node):

Directories to create:

```shell
sudo mkdir -p /var/log/patroni
sudo chown -R postgres:postgres /var/log/patroni

# For local WAL archiving (using archive_command):
sudo mkdir -p /archive/postgresql/pg-wal-archive/
# For local full backups:
sudo mkdir -p /archive/postgresql/pg-local-full-backup/systemd/
sudo chown -R postgres:postgres /archive/postgresql
```

#### 5. Install Patroni (Every Node):

Install Patroni and Stop and disable it if it's running

```shell
sudo apt install -y patroni
sudo systemctl disable --now patroni
```

#### 6. Put patroni config files in place (config.yml disable dcs.yml) (Every Node)

```shell
# We are not needing dcs.yml in our implementation
sudo mv /etc/patroni/dcs.yml /etc/patroni/dcs.yml.bak
sudo chown -R postgres:postgres /etc/patroni

```

#### 7. Modify the patroni's configuration file (Every Node):

Reference:

[YAML Configuration Settings, Patroni Documentation](https://patroni.readthedocs.io/en/latest/yaml_configuration.html)

```shell
sudo vi /etc/patroni/config.yml
```

The patroni's `.yml` configuration file should be something like the following on every node. Just note the <ins>node-specific
 configurations</ins> in this file
 
A `##### SHOULD BE CHANGED #####` line has been added before every line that should conventionally be changed for every cluster,
 more or less for your case.

<details>
<summary>(click to expand) The complete <b>patroni configuration file (config.yml)</b>:</summary>

```YAML
##### SHOULD BE CHANGED ##### PG Cluster Name&Version
scope: "17-main"
##### SHOULD BE CHANGED ##### Cluster Name
namespace: "maunleashdb"
##### SHOULD BE CHANGED ##### Node Name
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
##### SHOULD BE CHANGED ##### This Node Listen [IP] Address
  listen: 172.23.124.71:8008
##### SHOULD BE CHANGED ##### This Node Connect [IP] Address 
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
##### SHOULD BE CHANGED ##### ETCD Nodes [IP] Addresses
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
##### SHOULD BE CHANGED ##### This Node Connect [IP] Address 
  connect_address: 172.23.124.71:5432
  use_unix_socket: true
  ## Default Debian/Ubuntu directory layout
  # data_dir: @DATADIR_BASE@/@VERSION@/@CLUSTER@
  # bin_dir: /usr/lib/postgresql/@VERSION@/bin
  # config_dir: /etc/postgresql/@VERSION@/@CLUSTER@
  # pgpass: /var/lib/postgresql/@VERSION@-@CLUSTER@.pgpass
  # Modified directory layout:
##### SHOULD BE CHANGED ##### This Node data_dir 
  data_dir: /var/lib/postgresql/17/main/
##### SHOULD BE CHANGED ##### This Node bin_dir 
  bin_dir: /usr/lib/postgresql/17/bin
##### SHOULD BE CHANGED ##### This Node config_dir 
  config_dir: /etc/postgresql/17/main
  pgpass: /var/lib/postgresql/.pgpass
  
  authentication:
    replication:
##### SHOULD BE CHANGED ##### replicator user 
      username: "replicator"
##### SHOULD BE CHANGED ##### replicator user password
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
##### SHOULD BE CHANGED ##### superuser user password
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
##### SHOULD BE CHANGED ##### This Node data_directory 
    data_directory: '/var/lib/postgresql/17/main/'
    # network params:
    listen_addresses: "*"
    unix_socket_directories: '/var/run/postgresql/'
    # Emulate default Debian/Ubuntu logging
    logging_collector: 'on'
    log_directory: '/var/log/postgresql/'
##### SHOULD BE CHANGED ##### This Node Log File Name 
    log_filename: 'postgresql-17-main-%A.log'
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

As it is arranged for the Patroni service to run with the root user in this document, there is no need to change ownerships for this file.

#### 8. Install etcd (Every Node)

Latest version of etcd can be installed through its own website, and they strongly recommend
 that you do so and say that etcd version from pre-installed repositories is outdated. 

[https://etcd.io/docs/v3.5/install/](https://etcd.io/docs/v3.5/install/)

**However,** I have used Ubuntu's native repositories <ins>below</ins> to install etcd.

Install `etcd` and stop and disable it if it's running.

* On Ubuntu 22.04 and before:

```shell
sudo apt install -y etcd
sudo systemctl disable --now etcd
```

* On Ubuntu 24.04:

```shell
sudo apt install -y etcd-client etcd-discovery etcd-server
sudo systemctl disable --now etcd
```

Now, as said in the section `0`, we change the ownership of `/var/lib/etcd`
 to etcd.

```shell
sudo chown -R etcd:etcd /var/lib/etcd
```

#### 9. Make the etcd API version 3 global (Every Node)

Make it global by putting it inside /etc/profile

```shell
sudo echo >> /etc/profile
sudo echo export ETCDCTL_API=3 >> /etc/profile

```

Then make it effective for the current session too:

```shell
source /etc/profile
```

#### 10. Edit the /etc/default/etcd file (Every Node)

Reference:

[https://etcd.io/docs/v3.4/op-guide/configuration/](https://etcd.io/docs/v3.4/op-guide/configuration/)

```shell
sudo cp -a /etc/default/etcd /etc/default/etcd.default
sudo truncate -s 0 /etc/default/etcd
sudo vi /etc/default/etcd
```

Edit it like below:

```shell
ETCD_NAME=n1
ETCD_DATA_DIR="/var/lib/etcd/default"
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
pg_ctlcluster 17 main --skip-systemctl-redirect start
```

```PL/PGSQL
alter user postgres password 'p@ssvv0rcl';
create user replicator replication password 'p@ssvv0rcl';
select * from pg_user;
```

#### 12. Delete data directory contents (2nd and 3rd Nodes only)

Delete data directory contents on the 2nd and 3rd nodes only

```shell
sudo rm -rf /var/lib/postgresql/17/main/*
```

#### 13. Enable and start etcd service (Every Node)

Start `<ins>`from the first node `</ins>`, then go on with other nodes, as well. We want
 the first node to be the watchdog leader, thus we start from the first node.

```shell
sudo systemctl enable --now etcd
```

#### 14. Enable and start patroni service (First Node Only)

We want to start patroni for the first time. Thus, we want to make sure that postgresql is
 not running. PostgreSQL should be running because we manually started it to set the
 postgres user's password and create the other initial users.

We do these by executing the following commands:

```shell
pg_ctlcluster 17 main --skip-systemctl-redirect stop -m immediate
sudo systemctl enable --now patroni
```

#### 15. Enable and start patroni service (2nd and 3rd Nodes Only)

Now that the first node is taken care of, we go over to the 2nd and 3rd to enable and start the patroni
 service. The PGDATA directory and its contents will be created automatically using the patroni's
 built-in functionality:

```shell
sudo systemctl enable --now patroni
```

After running this, the key-value pairs will be created inside etcd and if you run the following command,
 a result like below should show up:

![1731832173916](image/PartISetupPostgreSQL,Patroni,andWatchdog/1731832173916.png)

* NOTE!

If after starting patroni service, the required key-value pairs are not created in etcd database like the figure
 below, there is bound to be something wrong with the patroni configurations, or the configurations do not
 match with postgresql or etcd.

For example, if you have not granted the replication privilege to the replicator
 user. Simple as that.

In such case, the empty command result like the latter figure might be shown:

![1731837384818](image/PartISetupPostgreSQL,Patroni,andWatchdog/1731837384818.png)


![1731837735829](image/PartISetupPostgreSQL,Patroni,andWatchdog/1731837735829.png)

## Setup VIP handling mechanism:

This can be done using some scripts and timers. However, for ease of use and setup we use `vip-manager`.

#### 16. Install vip-manager

Install and setup vip-manager (version 2). Then stop it if it's running:

```shell
sudo apt install -y vip-manager2
sudo systemctl stop vip-manager
```

#### 17. Edit vip-manager service:

We want to create a configuration file. Therefore, we need to modify the vip-manager service file to read
 from that configuration file upon start:

```shell
sudo systemctl edit vip-manager
```

Write the following inside the drop-in

```shell
[Service]

ExecStart=
ExecStart=/usr/bin/vip-manager --config=/etc/default/vip-manager.yml

```

Reload deamon:

```shell
sudo systemctl daemon-reload
```

#### 18. Create the vip-manager configuration file:

Create it with the address that we specified in the vip-manager service file:

```shell
sudo touch /etc/default/vip-manager.yml
```

#### 19. Config VIP Manager.

Set the configurations inside the vip-manager.yml file. The trigger-value must be specific to every node,
and it is typically the only directive that differs between the different nodes.

```YAML
trigger-value: "maunleash01"
```

<details>
<summary>(click to expand) Sample <b>vip-manager configuration file (vip-manager.yml)</b>:</summary>

```YAML
# config for vip-manager by Cybertec Schönig & Schönig GmbH

# time (in milliseconds) after which vip-manager wakes up and checks if it needs to register or release ip addresses.
interval: 1000

# the etcd or consul key which vip-manager will regularly poll.
trigger-key: "/maunleashdb/17-main/leader"
# if the value of the above key matches the trigger-value (often the hostname of this host), vip-manager will try to add the virtual ip address to the interface specified in Iface
trigger-value: "maunleash01"

ip: 172.23.124.74 # the virtual ip address to manage
netmask: 24 # netmask for the virtual ip
interface: ens160 #interface to which the virtual ip will be added

# how the virtual ip should be managed. we currently support "ip addr add/remove" through shell commands or the Hetzner api
hosting-type: basic # possible values: basic, or hetzner.

dcs-type: etcd # etcd or consul
# a list that contains all DCS endpoints to which vip-manager could talk.
dcs-endpoints:
  - http://127.0.0.1:2379
  - http://172.23.124.71:2379
  - http://172.23.124.72:2379
  - http://172.23.124.73:2379
  # A single list-item is also fine.
  # consul will always only use the first entry from this list.
  # For consul, you'll obviously need to change the port to 8500. Unless you're using a different one. Maybe you're a rebel and are running consul on port 2379? Just to confuse people? Why would you do that? Oh, I get it.

## etcd-user: "patroni"
## etcd-password: "Julian's secret password"
# when etcd-ca-file is specified, TLS connections to the etcd endpoints will be used.
## etcd-ca-file: "/path/to/etcd/trusted/ca/file"
# when etcd-cert-file and etcd-key-file are specified, we will authenticate at the etcd endpoints using this certificate and key.
## etcd-cert-file: "/path/to/etcd/client/cert/file"
## etcd-key-file: "/path/to/etcd/client/key/file"

# don't worry about parameter with a prefix that doesn't match the endpoint_type. You can write anything there, I won't even look at it.
## consul-token: "Julian's secret token"

# how often things should be retried and how long to wait between retries. (currently only affects arpClient)
retry-num: 2
retry-after: 250  #in milliseconds

# verbose logs (currently only supported for hetzner)
verbose: false

```

</details>


#### 20. Start+enable vip-manager service:

```shell
sudo systemctl enable --now vip-manager
```

# [Next: Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)

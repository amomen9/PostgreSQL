&nbsp;Doc parts:

* [Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)
* [Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)
* [Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)
* [Part IV: fix some glitches for Ubuntu](./Part%20IV%20fix%20some%20glitches%20for%20Ubuntu.md)
* [Part V: pgpool command, pcp, pgpool admin commands.md ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)
* [Part VI: Finish up, simulations, tests, notes.md ](./Part%20VI%20Finish%20up%2C%20simulations%2C%20tests%2C%20notes.md)


# PGPOOL (Ubuntu) Part II
**Install and Configure pgPool**

### Installation and Configuration of pgPool:

#### 2. Install pgpool (Every Node):
After adding the PostgreSQL's official repository, you can find pgpool and its related packages in that repository.

For pg version **15** (Ubuntu), you can execute the following:

```shell
sudo apt-get update
sudo apt-get install pgpool2 libpgpool2 postgresql-15-pgpool2
sudo chown -R postgres:postgres /etc/pgpool2
```

For pg version **16** (Ubuntu), you can execute the following:

```shell
sudo apt-get update
sudo apt-get install pgpool2 libpgpool2 postgresql-16-pgpool2
sudo chown -R postgres:postgres /etc/pgpool2
```

Note that the packages pgpool2, libpgpool2, and their dependents, do not rely on the PostgreSQL major version, however, the pgpool extensions (postgresql-15-pgpool2) for PostgreSQL database cluster engine do rely on the PostgreSQL's major version and must be chosen accordingly.
postgresql-15-pgpool2 contains extensions for pgpool and is mandatory too. They will be mentioned later. Choose the version of this package which corresponds with your pg major version.

#### 4. Create pgpool_node_id file (Every Node, but with different content)

create the pgpool_node_id file with the node id (ex 0) below on Every Node:
Write the following inside shell. The node id starts from 0 for Node 1, 1 for Node 2, and so on.

```shell
sudo -u postgres cat > /etc/pgpool2/pgpool_node_id << EOT
0
EOT
```

#### 5. Create the backend status file (Every Node)

It will be explained later. With the following commands, the `logdir` directive of pgpool.conf **must**
 be set to `'/var/log/pgpool'`.
```shell
sudo mkdir -p /var/log/pgpool
sudo touch /var/log/pgpool/pgpool_status		# Backend status file
sudo chown -R postgres:postgres /var/log/pgpool		# Log location
```


#### 9. Modify pcp.conf password file (Every Node)

It is used to define the pcp commands password. When you run the pcp commands, the password you provide there will be first converted to its MD5 hash, and then this hash will be checked against this file to see if the `<user>`:`<hashed password>` combination actually exist in this file. pcp.conf file path is /etc/pgpool2/pcp.conf by default. It shall have the following format:

`<user>:<hashed password>`

We obtain the hashed password by executing the following command:

```shell
pg_md5 <password>
```

**Be sure** to escape the special characters like $ or provide the password interactively.

![Screenshot_40](image/PartIInstallandConfigurePostgreSQLforpgPool/Screenshot_40.png)


Or if we want to enter the password in a more safe manner, we enter the following then type in the password:

```shell
pg_md5 -p
```

The mode for pcp.conf file should be 0755.

```shell
sudo chmod 0755 /etc/pgpool2/pcp.conf

sudo chown postgre:postgres /etc/pgpool2/pcp.conf
```

#### 10. Create pgpool pcp password file (.pcppass) (Every Node)

It is used to authenticate to the pcp commands without providing a password from the machine on which we create this file.

In fact, the password is taken from this file instead of directly entering it by the user when executing the pcp commands. The passwords that the pcp commands accept is recorded within pcp.conf file which we just explained. We place the .pcppass file under `~postgres`.

```shell
sudo vi ~postgres/.pcppass
```

It shall have the following format:
  
`hostname:port:username:password`

It also accepts * as wildcard. Here is what we fill inside this file. Again, the password is plain:

```conf
*:9898:pgpool:Pa$svvord
```

Save and close.

```shell
sudo chown -R postgres:postgres ~postgres
```


The .pcppass file must only be accessible by the owner. They must have 0600 mode. Note that we have defined the PCPPASSFILE env variable before too to point to the location that I mentioned. But even if we did not, the default location would be ~postgres/.pcppass

```shell
sudo -u postgres chmod 0600 ~postgres/.pcppass
```

#### 11. Create pgpool pool_passwd file (Every Node)

* Note!

You can only use one of MD5 and AES encryption algorithms for the users in this file.


It is used to connect to the pgpool proxy (which then redirects the user's query to one of the backends. The backend that it chooses depends on many factors. For example, node balancing measures, connecting to primary or secondary measures, etc.) on the pgpool port (9999 by default) without providing a password from the machine on which we create this file. 

In fact, the password is taken from this file instead of directly entering it by the user when connecting to the pgpool proxy. 

We place it under `/etc/pgpool2/` by default, because the default value of 'pool_passwd' directive in the pgpool.conf file is 'pool_passwd' which means the same directory relative to pgpool.conf. 

It shall have the following format:


`user:<encrypted password>`

First run the following:

```shell
sudo -u postgres touch /etc/pgpool2/pool_passwd
```

Unlike the previous files, it must not be filled manually, but by using one of the pg_md5 or pg_enc commands which are part of the pgpool2 package.
The difference between `pg_md5` and `pg_enc` is the encryption method. pg_md5 uses MD5, while pg_enc uses AES which is more concrete.

A sample of this file would be the following:

| postgres:`AES<AES encrypted string>`<br/><br/>pgpool:`MD5<MD5 encrypted string>`<br/><br/>repl:`AES<AES encrypted string>` |
| :----------------------------------------------------------------------------------------------------------- |

Encrypting using MD5 encryption:

![1721846962078](image/PartI/1721846962078.png)

```shell
sudo -u postgres pg_md5 -m -f /etc/pgpool2/pgpool.conf -K ~postgres/.pgpoolkey -u <username> -p
```

Repeat this for all the users that you want to create an entry for in this file using this encryption algorithm.
 Here we create and entry for postgres, pgpool, and repl users.

Some command-line arguments can be not provided if their values are the default ones. For example, the pgpool.conf file path (default is /etc/pgpool2/pgpool.conf).

You will be prompted to enter the user's password. -m flag will make the pg_md5 command to update the pool_passwd file automatically.

Encrypting using AES encryption:

![1721846962079](image/PartI/1721846962079.png)

pg_enc needs one extra necessity, which is the pgpool key. It can either be provided on the command-line as the pg_enc command demonstrates, or via .pgpoolkey file.
We use the .pgpoolkey file method. An encryption key must be manually provided here by the user:

```shell
sudo -u postgres cat > ~postgres/.pgpoolkey << EOT
<Encryption Key>
EOT

sudo -u postgres chmod 0600 ~postgres/.pgpoolkey
```

While .pgpoolkey is in the default location (~postgres/.pgpoolkey), it does not need to be provided for pg_enc as a command-line argument.

```shell
sudo -u postgres pg_enc -m -f /etc/pgpool2/pgpool.conf -K ~postgres/.pgpoolkey -u <username> -p
```
Repeat this for all the users that you want to create an entry for in this file using this encryption algorithm.
 Here we create and entry for postgres, pgpool, and repl users.

We can ignore some command-line arguments if their values are the default ones. For example, the pgpool.conf file path (default is /etc/pgpool2/pgpool.conf),
 the .pgpoolkey file path is ~/.pgpoolkey

You will be prompted to enter the user's password. -m flag will make the pg_md5 command to update the pool_passwd file automatically.

then

```
sudo chown -R postgres:postgres /etc/pgpool2
```

Finally, the pool_passwd file must only be accessible by the owner. They must have 0600 mode.

```shell
sudo -u postgres chmod 0600 /etc/pgpool2/pool_passwd
```

Run this to check the contents of this file. It will also confirm if the postgres user have read access to this file:

```shell
sudo -u postgres cat /etc/pgpool2/pool_passwd
```


#### 14. pgpool configuration files: pgpool.conf (Every Node)

The major configuration file for pgpool is pgpool.conf. Now we dive into this file. This is the default configuration file of pgpool 4.5.2. The parts that are commented out show the default value in effect for that directive. We have added some extra explainations for some parts. 

Furthermore, the only default directive that is not commented out by default is the following:

| backend_clustering_mode = 'streaming_replication' |
| :------------------------------------------------ |

The complete default pgpool.conf file that I have added additional explanations for some directives of it is as follows:

<details>
<summary>(click to expand) The complete default <b>pgpool.conf</b> file with added explanations:</summary>

```conf
# ----------------------------
# pgPool-II configuration file
# ----------------------------
#
# This file consists of lines of the form:
#
#   name = value
#
# Whitespace may be used.  Comments are introduced with "#" anywhere on a line.
# The complete list of parameter names and allowed values can be found in the
# pgPool-II documentation.
#
# This file is read on server startup and when the server receives a SIGHUP
# signal.  If you edit the file on a running system, you have to SIGHUP the
# server for the changes to take effect, or use "pgpool reload".  Some
# parameters, which are marked below, require a server shutdown and restart to
# take effect.
#

#------------------------------------------------------------------------------

# BACKEND CLUSTERING MODE

# Choose one of: 'streaming_replication', 'native_replication',

# 'logical_replication', 'slony', 'raw' or 'snapshot_isolation'

# (change requires restart)

#------------------------------------------------------------------------------

backend_clustering_mode = 'streaming_replication'

#------------------------------------------------------------------------------

# CONNECTIONS

#------------------------------------------------------------------------------

# - pgpool Connection Settings -

#listen_addresses = 'localhost'
                                   # what host name(s) or IP address(es) to listen on;
                                   # comma-separated list of addresses;
                                   # defaults to 'localhost'; use '*' for all
                                   # (change requires restart)
#port = 9999
                                   # Port number
                                   # (change requires restart)
#unix_socket_directories = '/var/run/postgresql'
                                   # Unix domain socket path(s)
                                   # The Debian package defaults to
                                   # /var/run/postgresql
                                   # (change requires restart)
#unix_socket_group = ''
                                   # The Owner group of Unix domain socket(s)
                                   # (change requires restart)
#unix_socket_permissions = 0777
                                   # Permissions of Unix domain socket(s)
                                   # (change requires restart)
#reserved_connections = 0
                                   # Number of reserved connections.
                                   # Pgpool-II does not accept connections if over
                                   # num_init_children - reserved_connections.

# When this parameter is set to 1 or greater, incoming connections from clients are not accepted with

# error message "Sorry, too many clients already", rather than blocked if the number of current

# connections from clients is more than (num_init_children - reserved_connections). For example, if

# reserved_connections = 1 and num_init_children = 32, then the 32th connection from a client will be refused.

# - pgpool Communication Manager Connection Settings -

# for pcp commands

#pcp_listen_addresses = 'localhost'
                                   # what host name(s) or IP address(es) for pcp process to listen on;
                                   # comma-separated list of addresses;
                                   # defaults to 'localhost'; use '*' for all
                                   # (change requires restart)
#pcp_port = 9898
                                   # Port number for pcp
                                   # (change requires restart)
#pcp_socket_dir = '/var/run/postgresql'
                                   # Unix domain socket path(s) for pcp
                                   # The Debian package defaults to
                                   # /var/run/postgresql
                                   # (change requires restart)
#listen_backlog_multiplier = 2
                                   # Set the backlog parameter of listen(2) to
                                   # num_init_children * listen_backlog_multiplier.
                                   # (change requires restart)

# Specifies the length of connection queue from frontend to Pgpool-II. Meaning the number of connections that are waiting in queue

# to be served by the pgpool proxy service.

#serialize_accept = off
                                   # whether to serialize accept() call to avoid thundering herd problem
                                   # (change requires restart)

# - Backend Connection Settings -

# Backends are the pg replicas

#backend_hostname0 = 'host1'
                                   # Host name or IP address to connect to for backend 0
#backend_port0 = 5432
                                   # Port number for backend 0
#backend_weight0 = 1
                                   # Weight for backend 0 (only in load balancing mode)
#backend_data_directory0 = '/data'
                                   # Data directory for backend 0
#backend_flag0 = 'ALLOW_TO_FAILOVER'
                                   # Controls various backend behavior
                                   # ALLOW_TO_FAILOVER, DISALLOW_TO_FAILOVER
                                   # or ALWAYS_PRIMARY
#backend_application_name0 = 'server0'
                                   # walsender's application_name, used for "show pool_nodes" command
#backend_hostname1 = 'host2'
#backend_port1 = 5433
#backend_weight1 = 1
#backend_data_directory1 = '/data1'
#backend_flag1 = 'ALLOW_TO_FAILOVER'
#backend_application_name1 = 'server1'

# - Authentication -

#enable_pool_hba = off
                                   # Use pool_hba.conf for client authentication
#pool_passwd = 'pool_passwd'
                                   # File name of pool_passwd for md5 authentication.
                                   # "" disables pool_passwd.
                                   # (change requires restart)
#authentication_timeout = 1min
                                   # Delay in seconds to complete client authentication
                                   # 0 means no timeout.

#allow_clear_text_frontend_auth = off
                                   # Allow Pgpool-II to use clear text password authentication
                                   # with clients, when pool_passwd does not
                                   # contain the user password

# Not recommended unless ssl connection is activated.

# - SSL Connections -

#ssl = off
                                   # Enable SSL support
                                   # (change requires restart)
#ssl_key = 'server.key'
                                   # SSL private key file
                                   # (change requires restart)
#ssl_cert = 'server.crt'
                                   # SSL public certificate file
                                   # (change requires restart)
#ssl_ca_cert = ''
                                   # Single PEM format file containing
                                   # CA root certificate(s)
                                   # (change requires restart)
#ssl_ca_cert_dir = ''
                                   # Directory containing CA root certificate(s)
                                   # (change requires restart)
#ssl_crl_file = ''
                                   # SSL certificate revocation list file
                                   # (change requires restart)

#ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
                                   # Allowed SSL ciphers
                                   # (change requires restart)
#ssl_prefer_server_ciphers = off
                                   # Use server's SSL cipher preferences,
                                   # rather than the client's
                                   # (change requires restart)
#ssl_ecdh_curve = 'prime256v1'
                                   # Name of the curve to use in ECDH key exchange
#ssl_dh_params_file = ''
                                   # Name of the file containing Diffie-Hellman parameters used
                                   # for so-called ephemeral DH family of SSL cipher.
#ssl_passphrase_command=''
                                   # Sets an external command to be invoked when a passphrase
                                   # for decrypting an SSL file needs to be obtained
                                   # (change requires restart)

#------------------------------------------------------------------------------

# POOLS

#------------------------------------------------------------------------------

# - Concurrent session and pool size -

#process_management_mode = static
                                   # process management mode for child processes
                                   # Valid options:
                                   # static: all children are pre-forked at startup
                                   # dynamic: child processes are spawned on demand.
                                   #      number of idle child processes at any time are
                                   #      configured by min_spare_children and max_spare_children

#process_management_strategy = gentle
                                   # process management strategy to satisfy spare processes
                                   # Valid options:
                                   #
                                   #    lazy: In this mode, the scale-down is performed gradually
                                   #     and only gets triggered when excessive spare processes count
                                   #     remains high for more than 5 mins
                                   #
                                   #    gentle: In this mode, the scale-down is performed gradually
                                   #     and only gets triggered when excessive spare processes count
                                   #     remains high for more than 2 mins
                                   #
                                   #    aggressive: In this mode, the scale-down is performed aggressively
                                   #     and gets triggered more frequently in case of higher spare processes.
                                   #     This mode uses faster and slightly less smart process selection criteria
                                   #     to identify the child processes that can be serviced to satisfy
                                   #     max_spare_children
                                   #
                                   # (Only applicable for dynamic process management mode)

#num_init_children = 32
                                   # Maximum Number of concurrent sessions allowed
                                   # (change requires restart)
#min_spare_children = 5
                                   # Minimum number of spare child processes waiting for connection
                                   # (Only applicable for dynamic process management mode)

#max_spare_children = 10
                                   # Maximum number of idle child processes waiting for connection
                                   # (Only applicable for dynamic process management mode)

#max_pool = 4
                                   # Number of connection pool caches per connection
                                   # (change requires restart)

# - Life time -

#child_life_time = 5min
                                   # Pool exits after being idle for this many seconds
#child_max_connections = 0
                                   # Pool exits after receiving that many connections
                                   # 0 means no exit
#connection_life_time = 0
                                   # Connection to backend closes after being idle for this many seconds
                                   # 0 means no close
#client_idle_limit = 0
                                   # Client is disconnected after being idle for that many seconds
                                   # (even inside an explicit transactions!)
                                   # 0 means no disconnection

#------------------------------------------------------------------------------

# LOGS

#------------------------------------------------------------------------------

# - Where to log -

#log_destination = 'stderr'
                                   # Where to log
                                   # Valid values are combinations of stderr,
                                   # and syslog. Default to stderr.

# - What to log -

#log_line_prefix = '%m: %a pid %p: '   # printf-style string to output at beginning of each log line.

#log_connections = off
                                   # Log connections
#log_disconnections = off
                                   # Log disconnections
#log_pcp_processes = on
                                   # Log PCP Processes
#log_hostname = off
                                   # Hostname will be shown in ps status
                                   # and in logs if connections are logged
#log_statement = off
                                   # Log all statements
#log_per_node_statement = off
                                   # Log all statements
                                   # with node and backend informations
#notice_per_node_statement = off
                                   # logs notice message for per node detailed SQL statements
#log_client_messages = off
                                   # Log any client messages

# Log messages that are returned to the client

#log_standby_delay = 'if_over_threshold'
                                   # Log standby delay
                                   # Valid values are combinations of always,
                                   # if_over_threshold, none

# - Syslog specific -

#syslog_facility = 'LOCAL0'
                                   # Syslog local facility. Default to LOCAL0
#syslog_ident = 'pgpool'
                                   # Syslog program identification string
                                   # Default to 'pgpool'

# - Debug -

#log_error_verbosity = default          # terse, default, or verbose messages

#client_min_messages = notice           # values in order of decreasing detail:
                                        #   debug5
                                        #   debug4
                                        #   debug3
                                        #   debug2
                                        #   debug1
                                        #   log
                                        #   notice
                                        #   warning
                                        #   error

# message levels that are returned to the client

#log_min_messages = warning             # values in order of decreasing detail:
                                        #   debug5
                                        #   debug4
                                        #   debug3
                                        #   debug2
                                        #   debug1
                                        #   info
                                        #   notice
                                        #   warning
                                        #   error
                                        #   log
                                        #   fatal
                                        #   panic

# This is used when logging to stderr:

#logging_collector = off
                                        # Enable capturing of stderr
                                        # into log files.
                                        # (change requires restart)

# -- Only used if logging_collector is on ---

#log_directory = '/tmp/pgpool_logs'
                                        # directory where log files are written,
                                        # can be absolute
#log_filename = 'pgpool-%Y-%m-%d_%H%M%S.log'
                                        # log file name pattern,
                                        # can include strftime() escapes

#log_file_mode = 0600
                                        # creation mode for log files,
                                        # begin with 0 to use octal notation

#log_truncate_on_rotation = off
                                        # If on, an existing log file with the
                                        # same name as the new log file will be
                                        # truncated rather than appended to.
                                        # But such truncation only occurs on
                                        # time-driven rotation, not on restarts
                                        # or size-driven rotation.  Default is
                                        # off, meaning append to existing files
                                        # in all cases.

#log_rotation_age = 1d
                                        # Automatic rotation of logfiles will
                                        # happen after that (minutes)time.
                                        # 0 disables time based rotation.
#log_rotation_size = 10MB
                                        # Automatic rotation of logfiles will
                                        # happen after that much (KB) log output.
                                        # 0 disables size based rotation.
#------------------------------------------------------------------------------

# FILE LOCATIONS

#------------------------------------------------------------------------------

#pid_file_name = '/var/run/postgresql/pgpool.pid'
                                   # PID file name
                                   # Can be specified as relative to the"
                                   # location of pgpool.conf file or
                                   # as an absolute path
                                   # (change requires restart)
#logdir = '/var/log/postgresql'
                                   # Directory of pgPool status file
                                   # (change requires restart)

#------------------------------------------------------------------------------

# CONNECTION POOLING

#------------------------------------------------------------------------------

#connection_cache = on
                                   # Activate connection pools
                                   # (change requires restart)

    # Semicolon separated list of queries
                                   # to be issued at the end of a session
                                   # The default is for 8.3 and later
#reset_query_list = 'ABORT; DISCARD ALL'
                                   # The following one is for 8.2 and before
#reset_query_list = 'ABORT; RESET ALL; SET SESSION AUTHORIZATION DEFAULT'

#------------------------------------------------------------------------------

# REPLICATION MODE

#------------------------------------------------------------------------------

#replicate_select = off
                                   # Replicate SELECT statements
                                   # when in replication mode
                                   # replicate_select is higher priority than
                                   # load_balance_mode.

# For data consistency purposes to see if the result sets differ

#insert_lock = on
                                   # Automatically locks a dummy row or a table
                                   # with INSERT statements to keep SERIAL data
                                   # consistency
                                   # Without SERIAL, no lock will be issued
#lobj_lock_table = ''
                                   # When rewriting lo_creat command in
                                   # replication mode, specify table name to
                                   # lock

# - Degenerate handling -

#replication_stop_on_mismatch = off
                                   # On disagreement with the packet kind
                                   # sent from backend, degenerate the node
                                   # which is most likely "minority"
                                   # If off, just force to exit this session

#failover_if_affected_tuples_mismatch = off
                                   # On disagreement with the number of affected
                                   # tuples in UPDATE/DELETE queries, then
                                   # degenerate the node which is most likely
                                   # "minority".
                                   # If off, just abort the transaction to
                                   # keep the consistency

#------------------------------------------------------------------------------

# LOAD BALANCING MODE

#------------------------------------------------------------------------------
# Some parameters depend on wether the other nodes are synchronous or not

#load_balance_mode = on
                                   # Activate load balancing mode
                                   # (change requires restart)
#ignore_leading_white_space = on
                                   # Ignore leading white spaces of each query
#read_only_function_list = ''
                                   # Comma separated list of function names
                                   # that don't write to database
                                   # Regexp are accepted
#write_function_list = ''
                                   # Comma separated list of function names
                                   # that write to database
                                   # Regexp are accepted
                                   # If both read_only_function_list and write_function_list
                                   # is empty, function's volatile property is checked.
                                   # If it's volatile, the function is regarded as a
                                   # writing function.

#primary_routing_query_pattern_list = ''
                                   # Semicolon separated list of query patterns
                                   # that should be sent to primary node
                                   # Regexp are accepted
                                   # valid for streaming replication mode only.

#user_redirect_preference_list = ''
                                   # comma separated list of pairs of user name and node id.
                                   # example: postgres:primary,user[0-4]:1,user[5-9]:2'
                                   # valid for streaming replication mode only.

#database_redirect_preference_list = ''
                                   # comma separated list of pairs of database and node id.
                                   # example: postgres:primary,mydb[0-4]:1,mydb[5-9]:2'
                                   # valid for streaming replication mode only.

#app_name_redirect_preference_list = ''
                                   # comma separated list of pairs of app name and node id.
                                   # example: 'psql:primary,myapp[0-4]:1,myapp[5-9]:standby'
                                   # valid for streaming replication mode only.

#allow_sql_comments = off
                                   # if on, ignore SQL comments when judging if load balance or
                                   # query cache is possible.
                                   # If off, SQL comments effectively prevent the judgment
                                   # (pre 3.4 behavior).
# Tell pgpool whether it should take account of SQL comments inside the incomming SQL Statements

#disable_load_balance_on_write = 'transaction'
                                   # Load balance behavior when write query is issued
                                   # in an explicit transaction.
                                   #
                                   # Valid values:
                                   #
                                   # 'transaction' (default):
                                   #     if a write query is issued, subsequent
                                   #     read queries will not be load balanced
                                   #     until the transaction ends.
                                   #
                                   # 'trans_transaction':
                                   #     if a write query is issued, subsequent
                                   #     read queries in an explicit transaction
                                   #     will not be load balanced until the session ends.
                                   #
                                   # 'dml_adaptive':
                                   #     Queries on the tables that have already been
                                   #     modified within the current explicit transaction will
                                   #     not be load balanced until the end of the transaction.
                                   #
                                   # 'always':
                                   #     if a write query is issued, read queries will
                                   #     not be load balanced until the session ends.
                                   #
                                   # Note that any query not in an explicit transaction
                                   # is not affected by the parameter except 'always'.
#Queries on the tables that have already been
#modified within the current explicit transaction will
#not be load balanced until the end of the transaction.

#dml_adaptive_object_relationship_list= ''
                                   # comma separated list of object pairs
                                   # [object]:[dependent-object], to disable load balancing
                                   # of dependent objects within the explicit transaction
                                   # after WRITE statement is issued on (depending-on) object.
                                   #
                                   # example: 'tb_t1:tb_t2,insert_tb_f_func():tb_f,tb_v:my_view'
                                   # Note: function name in this list must also be present in
                                   # the write_function_list
                                   # only valid for disable_load_balance_on_write = 'dml_adaptive'.

#statement_level_load_balance = off
                                   # Enables statement level load balancing

#------------------------------------------------------------------------------

# STREAMING REPLICATION MODE

#------------------------------------------------------------------------------

# - Streaming -

#sr_check_period = 10
                                   # Streaming replication check period
                                   # Default is 10s.
#sr_check_user = 'nobody'
                                   # Streaming replication check user
                                   # This is necessary even if you disable streaming
                                   # replication delay check by sr_check_period = 0
#sr_check_password = ''
                                   # Password for streaming replication check user
                                   # Leaving it empty will make Pgpool-II to first look for the
                                   # Password in pool_passwd file before using the empty password

#sr_check_database = 'postgres'
                                   # Database name for streaming replication check
#delay_threshold = 0
                                   # Threshold before not dispatching query to standby node
                                   # Unit is in bytes
                                   # Disabled (0) by default
# Specifies the maximum tolerance level of replication delay in WAL bytes on the standby server against the primary server
# If the delay exceeds this configured level, Pgpool-II stops sending the SELECT queries to the standby server and starts 
# routing everything to the primary server even if load_balance_mode is enabled, until the standby catches-up with the primary

#delay_threshold_by_time = 0
                                   # Threshold before not dispatching query to standby node
                                   # The default unit is in millisecond(s)
                                   # Disabled (0) by default

#prefer_lower_delay_standby = off
                                   # If delay_threshold is set larger than 0, Pgpool-II send to
                                   # the primary when selected node is delayed over delay_threshold.
                                   # If this is set to on, Pgpool-II send query to other standby
                                   # delayed lower.

# - Special commands -

#follow_primary_command = ''
                                   # Executes this command after main node failover
                                   # Special values:
                                   #   %d = failed node id
                                   #   %h = failed node host name
                                   #   %p = failed node port number
                                   #   %D = failed node database cluster path
                                   #   %m = new main node id
                                   #   %H = new main node hostname
                                   #   %M = old main node id
                                   #   %P = old primary node id
                                   #   %r = new main port number
                                   #   %R = new main database cluster path
                                   #   %N = old primary node hostname
                                   #   %S = old primary node port number
                                   #   %% = '%' character

# a shell command which is usually the path of a script file which is executed on an special event

# for this specific directive, this script has a suggested template by pgpool and is executed after

# a manual failover for the old primary to arrive to a common point of recovery with the new primary

# usually follow_primary.sh

#------------------------------------------------------------------------------

# HEALTH CHECK GLOBAL PARAMETERS

#------------------------------------------------------------------------------

#health_check_period = 0
                                   # Health check period
                                   # Disabled (0) by default
#health_check_timeout = 20
                                   # Health check timeout
                                   # 0 means no timeout
#health_check_user = 'nobody'
                                   # Health check user
#health_check_password = ''
                                   # Password for health check user
                                   # Leaving it empty will make Pgpool-II to first look for the
                                   # Password in pool_passwd file before using the empty password

#health_check_database = ''
                                   # Database name for health check. If '', tries 'postgres' frist,
#health_check_max_retries = 0
                                   # Maximum number of times to retry a failed health check before giving up.
#health_check_retry_delay = 1
                                   # Amount of time to wait (in seconds) between retries.
#connect_timeout = 10000
                                   # Timeout value in milliseconds before giving up to connect to backend.
                                   # Default is 10000 ms (10 second). Flaky network user may want to increase
                                   # the value. 0 means no timeout.
                                   # Note that this value is not only used for health check,
                                   # but also for ordinary connection to backend.

#------------------------------------------------------------------------------

# HEALTH CHECK PER NODE PARAMETERS (OPTIONAL)

#------------------------------------------------------------------------------

# You can specify configurations for specific nodes if you want them to differ

# from others

#health_check_period0 = 0
#health_check_timeout0 = 20
#health_check_user0 = 'nobody'
#health_check_password0 = ''
#health_check_database0 = ''
#health_check_max_retries0 = 0
#health_check_retry_delay0 = 1
#connect_timeout0 = 10000

#------------------------------------------------------------------------------

# FAILOVER AND FAILBACK

#------------------------------------------------------------------------------

#failover_command = ''
                                   # Executes this command at failover
                                   # Special values:
                                   #   %d = failed node id
                                   #   %h = failed node host name
                                   #   %p = failed node port number
                                   #   %D = failed node database cluster path
                                   #   %m = new main node id
                                   #   %H = new main node hostname
                                   #   %M = old main node id
                                   #   %P = old primary node id
                                   #   %r = new main port number
                                   #   %R = new main database cluster path
                                   #   %N = old primary node hostname
                                   #   %S = old primary node port number
                                   #   %% = '%' character

# executed when a failover is triggered. Either through a primary server crash or a manual failover.

# usually failover.sh

#failback_command = ''
                                   # Executes this command at failback.
                                   # Special values:
                                   #   %d = failed node id
                                   #   %h = failed node host name
                                   #   %p = failed node port number
                                   #   %D = failed node database cluster path
                                   #   %m = new main node id
                                   #   %H = new main node hostname
                                   #   %M = old main node id
                                   #   %P = old primary node id
                                   #   %r = new main port number
                                   #   %R = new main database cluster path
                                   #   %N = old primary node hostname
                                   #   %S = old primary node port number
                                   #   %% = '%' character

#failover_on_backend_error = on
                                   # Initiates failover when reading/writing to the
                                   # backend communication socket fails
                                   # If set to off, pgpool will report an
                                   # error and disconnect the session.

#failover_on_backend_shutdown = off
                                   # Initiates failover when backend is shutdown,
                                   # or backend process is killed.
                                   # If set to off, pgpool will report an
                                   # error and disconnect the session.

#detach_false_primary = off
                                   # Detach false primary if on. Only
                                   # valid in streaming replication
                                   # mode and with PostgreSQL 9.6 or
                                   # after.

#search_primary_node_timeout = 5min
                                   # Timeout in seconds to search for the
                                   # primary node when a failover occurs.
                                   # 0 means no timeout, keep searching
                                   # for a primary node forever.

#------------------------------------------------------------------------------

# ONLINE RECOVERY

#------------------------------------------------------------------------------

# used for recovering a node from another node (primary is preferable).

#recovery_user = 'nobody'
                                   # Online recovery user
#recovery_password = ''
                                   # Online recovery password
                                   # Leaving it empty will make Pgpool-II to first look for the
                                   # Password in pool_passwd file before using the empty password

#recovery_1st_stage_command = ''
                                   # Executes a command in first stage

# Usually recovery_1st_stage script file

#recovery_2nd_stage_command = ''
                                   # Executes a command in second stage
#recovery_timeout = 90
                                   # Timeout in seconds to wait for the
                                   # recovering node's postmaster to start up
                                   # 0 means no wait
#client_idle_limit_in_recovery = 0
                                   # Client is disconnected after being idle
                                   # for that many seconds in the second stage
                                   # of online recovery
                                   # 0 means no disconnection
                                   # -1 means immediate disconnection

#auto_failback = off
                                   # Detached backend node reattach automatically
                                   # if replicatiotate is 'streaming'.
#auto_failback_interval = 1min
                                   # Min interval of executing auto_failback in
                                   # seconds.

#------------------------------------------------------------------------------

# WATCHDOG

#------------------------------------------------------------------------------

# - Enabling -

#use_watchdog = off
                                    # Activates watchdog
                                    # (change requires restart)

# -Connection to upstream servers -

#trusted_servers = ''
                                    # trusted server list which are used
                                    # to confirm network connection
                                    # (hostA,hostB,hostC,...)
                                    # (change requires restart)

#trusted_server_command = 'ping -q -c3 %h'
                                    # Command to execute when communicate trusted server.
                                    # Special values:
                                    #   %h = host name specified by trusted_servers

# - Watchdog communication Settings -

#hostname0 = ''
                                    # Host name or IP address of pgpool node
                                    # for watchdog connection
                                    # (change requires restart)
#wd_port0 = 9000
                                    # Port number for watchdog service
                                    # (change requires restart)
#pgpool_port0 = 9999
                                    # Port number for pgpool
                                    # (change requires restart)

#hostname1 = ''
#wd_port1 = 9000
#pgpool_port1 = 9999

#hostname2 = ''
#wd_port2 = 9000
#pgpool_port2 = 9999

#wd_priority = 1
                                    # priority of this watchdog in leader election
                                    # (change requires restart)

#wd_authkey = ''
                                    # Authentication key for watchdog communication
                                    # (change requires restart)

#wd_ipc_socket_dir = '/tmp'
                                    # Unix domain socket path for watchdog IPC socket
                                    # The Debian package defaults to
                                    # /var/run/postgresql
                                    # (change requires restart)

# - Virtual IP control Setting -

#delegate_ip = ''
                                    # delegate IP address
                                    # If this is empty, virtual IP never bring up.
                                    # (change requires restart)
#if_cmd_path = '/sbin'
                                    # path to the directory where if_up/down_cmd exists
                                    # If if_up/down_cmd starts with "/", if_cmd_path will be ignored.
                                    # (change requires restart)
#if_up_cmd = '/usr/bin/sudo /sbin/ip addr add $_IP_$/24 dev eth0 label eth0:0'
                                    # startup delegate IP command
                                    # (change requires restart)

# Command to bring up the floating IP

#if_down_cmd = '/usr/bin/sudo /sbin/ip addr del $_IP_$/24 dev eth0'
                                    # shutdown delegate IP command
                                    # (change requires restart)

# Command to bring down the floating IP

#arping_path = '/usr/sbin'
                                    # arping command path
                                    # If arping_cmd starts with "/", if_cmd_path will be ignored.
                                    # (change requires restart)
# Note: requires iputils-arping to be installed on Ubuntu

#arping_cmd = '/usr/bin/sudo /usr/sbin/arping -U $_IP_$ -w 1 -I eth0'
                                    # arping command
                                    # (change requires restart)

#ping_path = '/bin'
                                    # ping command path
                                    # (change requires restart)

# - Behaivor on escalation Setting -

#clear_memqcache_on_escalation = on
                                    # Clear all the query cache on shared memory
                                    # when standby pgpool escalate to active pgpool
                                    # (= virtual IP holder).
                                    # This should be off if client connects to pgpool
                                    # not using virtual IP.
                                    # (change requires restart)
#wd_escalation_command = ''
                                    # Executes this command at escalation on new active pgpool.
                                    # (change requires restart)

# executes escalation.sh

#wd_de_escalation_command = ''
                                    # Executes this command when leader pgpool resigns from being leader.
                                    # (change requires restart)

# - Watchdog consensus settings for failover -

#failover_when_quorum_exists = on
                                    # Only perform backend node failover
                                    # when the watchdog cluster holds the quorum
                                    # (change requires restart)

#failover_require_consensus = on
                                    # Perform failover when majority of Pgpool-II nodes
                                    # aggrees on the backend node status change
                                    # (change requires restart)

#allow_multiple_failover_requests_from_node = off
                                    # A Pgpool-II node can cast multiple votes
                                    # for building the consensus on failover
                                    # (change requires restart)

#enable_consensus_with_half_votes = off
                                    # apply majority rule for consensus and quorum computation
                                    # at 50% of votes in a cluster with even number of nodes.
                                    # when enabled the existence of quorum and consensus
                                    # on failover is resolved after receiving half of the
                                    # total votes in the cluster, otherwise both these
                                    # decisions require at least one more vote than
                                    # half of the total votes.
                                    # (change requires restart)

# - Watchdog cluster membership settings for quorum computation -

#wd_remove_shutdown_nodes = off
                                    # when enabled cluster membership of properly shutdown
                                    # watchdog nodes gets revoked, After that the node does
                                    # not count towards the quorum and consensus computations

#wd_lost_node_removal_timeout = 0s
                                    # Timeout after which the cluster membership of LOST watchdog
                                    # nodes gets revoked. After that the node node does not
                                    # count towards the quorum and consensus computations
                                    # setting timeout to 0 will never revoke the membership
                                    # of LOST nodes

#wd_no_show_node_removal_timeout = 0s
                                    # Time to wait for Watchdog node to connect to the cluster.
                                    # After that time the cluster membership of NO-SHOW node gets
                                    # revoked and it does not count towards the quorum and
                                    # consensus computations
                                    # setting timeout to 0 will not revoke the membership
                                    # of NO-SHOW nodes

# - Lifecheck Setting -

# -- common --

#wd_monitoring_interfaces_list = ''
                                    # Comma separated list of interfaces names to monitor.
                                    # if any interface from the list is active the watchdog will
                                    # consider the network is fine
                                    # 'any' to enable monitoring on all interfaces except loopback
                                    # '' to disable monitoring
                                    # (change requires restart)

#wd_lifecheck_method = 'heartbeat'
                                    # Method of watchdog lifecheck ('heartbeat' or 'query' or 'external')
                                    # (change requires restart)
#wd_interval = 10
                                    # lifecheck interval (sec) > 0
                                    # (change requires restart)

# -- heartbeat mode --

# if heartbeat mode has been chosen in wd_lifecheck_method

#heartbeat_hostname0 = ''
                                    # Host name or IP address used
                                    # for sending heartbeat signal.
                                    # (change requires restart)
#heartbeat_port0 = 9694
                                    # Port number used for receiving/sending heartbeat signal
                                    # Usually this is the same as heartbeat_portX.
                                    # (change requires restart)
#heartbeat_device0 = ''
                                    # Name of NIC device (such like 'eth0')
                                    # used for sending/receiving heartbeat
                                    # signal to/from destination 0.
                                    # This works only when this is not empty
                                    # and pgpool has root privilege.
                                    # (change requires restart)

#heartbeat_hostname1 = ''
#heartbeat_port1 = 9694
#heartbeat_device1 = ''
#heartbeat_hostname2 = ''
#heartbeat_port2 = 9694
#heartbeat_device2 = ''

#wd_heartbeat_keepalive = 2
                                    # Interval time of sending heartbeat signal (sec)
                                    # (change requires restart)
#wd_heartbeat_deadtime = 30
                                    # Deadtime interval for heartbeat signal (sec)
                                    # (change requires restart)

# -- query mode --

#wd_life_point = 3
                                    # lifecheck retry times
                                    # (change requires restart)
#wd_lifecheck_query = 'SELECT 1'
                                    # lifecheck query to pgpool from watchdog
                                    # (change requires restart)
#wd_lifecheck_dbname = 'template1'
                                    # Database name connected for lifecheck
                                    # (change requires restart)
#wd_lifecheck_user = 'nobody'
                                    # watchdog user monitoring pgpools in lifecheck
                                    # (change requires restart)
#wd_lifecheck_password = ''
                                    # Password for watchdog user in lifecheck
                                    # Leaving it empty will make Pgpool-II to first look for the
                                    # Password in pool_passwd file before using the empty password
                                    # (change requires restart)

#------------------------------------------------------------------------------

# OTHERS

#------------------------------------------------------------------------------
#relcache_expire = 0
                                   # Life time of relation cache in seconds.
                                   # 0 means no cache expiration(the default).
                                   # The relation cache is used for cache the
                                   # query result against PostgreSQL system
                                   # catalog to obtain various information
                                   # including table structures or if it's a
                                   # temporary table or not. The cache is
                                   # maintained in a pgpool child local memory
                                   # and being kept as long as it survives.
                                   # If someone modify the table by using
                                   # ALTER TABLE or some such, the relcache is
                                   # not consistent anymore.
                                   # For this purpose, cache_expiration
                                   # controls the life time of the cache.
#relcache_size = 256
                                   # Number of relation cache
                                   # entry. If you see frequently:
                                   # "pool_search_relcache: cache replacement happened"
                                   # in the pgpool log, you might want to increate this number.

#check_temp_table = catalog
                                   # Temporary table check method. catalog, trace or none.
                                   # Default is catalog.

# Setting to catalog or trace, enables the temporary table check in the SELECT statements. To

# check the temporary table Pgpool-II queries the system catalog of primary/main PostgreSQL

# backend if catalog is specified, which increases the load on the primary/main server.

# If trace is set, Pgpool-II traces temporary table creation and dropping to obtain temporary

# table info. So no need to access system catalogs. However, if temporary table creation is

# invisible to Pgpool-II (done in functions or triggers, for example), Pgpool-II cannot recognize

# the creation of temporary tables.

#check_unlogged_table = on
                                   # If on, enable unlogged table check in SELECT statements.
                                   # This initiates queries against system catalog of primary/main
                                   # thus increases load of primary.
                                   # If you are absolutely sure that your system never uses unlogged tables
                                   # and you want to save access to primary/main, you could turn this off.
                                   # Default is on.
#enable_shared_relcache = on
                                   # If on, relation cache stored in memory cache,
                                   # the cache is shared among child process.
                                   # Default is on.
                                   # (change requires restart)

# By setting to on, relation cache is shared among Pgpool-II child processes using the in memory query cache (see

# Section 5.12.1 for more details). Default is on. Each child process needs to access to the system catalog from

# PostgreSQL. By enabling this feature, other process can extract the catalog lookup result from the query cache

# and it should reduce the frequency of the query. Cache invalidation is not happen even if the system catalog is

# modified. So it is strongly recommend to set time out base cache invalidation by using relcache_expire parameter.

#relcache_query_target = primary
                                   # Target node to send relcache queries. Default is primary node.
                                   # If load_balance_node is specified, queries will be sent to load balance node.
#------------------------------------------------------------------------------

# IN MEMORY QUERY MEMORY CACHE

#------------------------------------------------------------------------------
#memory_cache_enabled = off
                                   # If on, use the memory cache functionality, off by default
                                   # (change requires restart)
#memqcache_method = 'shmem'
                                   # Cache storage method. either 'shmem'(shared memory) or
                                   # 'memcached'. 'shmem' by default
                                   # (change requires restart)
#memqcache_memcached_host = 'localhost'
                                   # Memcached host name or IP address. Mandatory if
                                   # memqcache_method = 'memcached'.
                                   # Defaults to localhost.
                                   # (change requires restart)
#memqcache_memcached_port = 11211
                                   # Memcached port number. Mondatory if memqcache_method = 'memcached'.
                                   # Defaults to 11211.
                                   # (change requires restart)
#memqcache_total_size = 64MB
                                   # Total memory size in bytes for storing memory cache.
                                   # Mandatory if memqcache_method = 'shmem'.
                                   # Defaults to 64MB.
                                   # (change requires restart)
#memqcache_max_num_cache = 1000000
                                   # Total number of cache entries. Mandatory
                                   # if memqcache_method = 'shmem'.
                                   # Each cache entry consumes 48 bytes on shared memory.
                                   # Defaults to 1,000,000(45.8MB).
                                   # (change requires restart)
#memqcache_expire = 0
                                   # Memory cache entry life time specified in seconds.
                                   # 0 means infinite life time. 0 by default.
                                   # (change requires restart)
#memqcache_auto_cache_invalidation = on
                                   # If on, invalidation of query cache is triggered by corresponding
                                   # DDL/DML/DCL(and memqcache_expire).  If off, it is only triggered
                                   # by memqcache_expire.  on by default.
                                   # (change requires restart)
#memqcache_maxcache = 400kB
                                   # Maximum SELECT result size in bytes.
                                   # Must be smaller than memqcache_cache_block_size. Defaults to 400KB.
                                   # (change requires restart)
#memqcache_cache_block_size = 1MB
                                   # Cache block size in bytes. Mandatory if memqcache_method = 'shmem'.
                                   # Defaults to 1MB.
                                   # (change requires restart)
#memqcache_oiddir = '/var/log/pgpool/oiddir'
                                   # Temporary work directory to record table oids
                                   # (change requires restart)
#cache_safe_memqcache_table_list = ''
                                   # Comma separated list of table names to memcache
                                   # that don't write to database
                                   # Regexp are accepted
#cache_unsafe_memqcache_table_list = ''
                                   # Comma separated list of table names not to memcache
                                   # that don't write to database
                                   # Regexp are accepted

# list of tables that their records frequently change.
```

</details>

* **Note:**

When password directives are left empty, pgpool will first examine the pool_passwd file, then try to use empty password.

* Now, this is the pgpool.conf file summarized for our production env specific needs. Some directives are picked, the others are not included to be left with their default values. Some values are default, but they are included anyway for future manipulation and attention. 
* The check (healthcheck, heartbeat signal, and sr check) parameters are specified with the assumption that all our nodes are on the same fast and stably connected network. Though for a disaster node which is in a far location and on a relatively slowly connected network, different "PER NODE PARAMETERS" options should be specified. 
* Note that if_up_cmd/if_down_cmd directives must be modified to have your correct interface name. For example, if you interface name is ens160, they would be the following:
		
```conf
if_up_cmd = '/usr/bin/sudo /usr/sbin/ip addr add $_IP_$/24 dev ens160 label ens160:0'		# If the interface name is ens160
```
		
```conf
if_down_cmd = '/usr/bin/sudo /usr/sbin/ip addr del $_IP_$/24 dev ens160'		# If the interface name is ens160
```

* We use the pgpool's pool_hba, CONNECTION POOLING, LOAD BALANCING, FAILOVER AND FAILBACK, ONLINE RECOVERY, WATCHDOG, RELCACHE, and IN MEMORY QUERY MEMORY CACHE features:

```shell
sudo -u postgres truncate -s 0 /etc/pgpool2/pgpool.conf
sudo -u postgres vi /etc/pgpool2/pgpool.conf
```

Copy the contents of the following file inside vim. Perform the modifications of your choice if you
 deem necessary:

<details>
<summary>(click to expand) pgpool.conf summary:</summary>

```conf
######################### Optimized for our case-specific Production ############################

#------------------------------------------------------------------------------
# BACKEND CLUSTERING MODE
#------------------------------------------------------------------------------
backend_clustering_mode = 'streaming_replication'

#------------------------------------------------------------------------------
# CONNECTIONS
#------------------------------------------------------------------------------

listen_addresses = '*'
port = 9999
socket_dir = '/var/run/postgresql'
#socket_dir = '/tmp'


pcp_listen_addresses = '*'
pcp_port = 9898
pcp_socket_dir = '/var/run/postgresql'
#pcp_socket_dir = '/tmp'

listen_backlog_multiplier = 2

# Replica Configurations

# - Authentication -
enable_pool_hba = on

#------------------------------------------------------------------------------
# POOLS
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# LOGS
#------------------------------------------------------------------------------

log_connections = on
log_hostname = on
log_statement = off
log_per_node_statement = off
logging_collector = on
log_error_verbosity = default
log_client_messages = off
syslog_ident = 'pgpool'
client_min_messages = notice
log_min_messages = warning
log_truncate_on_rotation = on
log_rotation_age = 7d
log_rotation_size = 512MB
log_directory = '/tmp/pgpool_logs'

#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------

# pgpool_status file location
logdir = '/var/log/pgpool/'

#------------------------------------------------------------------------------
# CONNECTION POOLING
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# REPLICATION MODE
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# LOAD BALANCING MODE
#------------------------------------------------------------------------------
# Some parameters depend on wether the other nodes are synchronous or not

load_balance_mode = on
allow_sql_comments = on
disable_load_balance_on_write = 'transaction'
statement_level_load_balance = off

#------------------------------------------------------------------------------
# STREAMING REPLICATION MODE
#------------------------------------------------------------------------------

sr_check_period = 10
sr_check_user = 'repl'
sr_check_password = ''
delay_threshold = 10001
follow_primary_command = '/bin/sh /etc/pgpool2/scripts/follow_primary.sh %d %h %p %D %m %H %M %P %r %R'

#------------------------------------------------------------------------------
# HEALTH CHECK GLOBAL PARAMETERS
#------------------------------------------------------------------------------

health_check_period = 5
health_check_timeout = 2
health_check_user = 'pgpool'
health_check_password = ''
health_check_database = 'postgres'
health_check_max_retries = 1
health_check_retry_delay = 1
connect_timeout = 2000

#------------------------------------------------------------------------------
# HEALTH CHECK PER NODE PARAMETERS (OPTIONAL)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# FAILOVER AND FAILBACK
#------------------------------------------------------------------------------

failover_on_backend_shutdown = on
failover_on_backend_error = on
detach_false_primary = on
failover_command = '/bin/sh /etc/pgpool2/scripts/failover.sh %d %h %p %D %m %H %M %P %r %R %N %S'
failback_command = ''

#------------------------------------------------------------------------------
# ONLINE RECOVERY
#------------------------------------------------------------------------------

recovery_user = 'postgres'
recovery_password = ''
recovery_1st_stage_command = '/bin/sh $PGDATA/recovery_1st_stage'
recovery_2nd_stage_command = ''

#------------------------------------------------------------------------------
# WATCHDOG
#------------------------------------------------------------------------------


use_watchdog = on

# -Connection to upstream servers -
trusted_servers = 'funleashpgdb01,funleashpgdb02,funleashpgdb03'
trusted_server_command = 'ping -q -c3 %h'

# - Watchdog communication Settings -
hostname0 = 'funleashpgdb01'
wd_port0 = 9000
pgpool_port0 = 9999
hostname1 = 'funleashpgdb02'
wd_port1 = 9000
pgpool_port1 = 9999
hostname2 = 'funleashpgdb03'
wd_port2 = 9000
pgpool_port2 = 9999
wd_ipc_socket_dir = '/var/run/postgresql'

# - Virtual IP control Setting -
ping_path = '/usr/bin'
delegate_ip = '172.23.124.74'
if_cmd_path = '/usr/sbin'
if_up_cmd = '/usr/bin/sudo /usr/sbin/ip addr add $_IP_$/24 dev ens160 label ens160:0'
if_down_cmd = '/usr/bin/sudo /usr/sbin/ip addr del $_IP_$/24 dev ens160'
arping_path = '/usr/bin'
arping_cmd = '/usr/bin/sudo /usr/sbin/arping -U $_IP_$ -w 1 -I ens160'

# - Behaivor on escalation Setting -
clear_memqcache_on_escalation = off
wd_escalation_command = '/bin/sh /etc/pgpool2/scripts/escalation.sh'
enable_consensus_with_half_votes = off
wd_de_escalation_command = ''

# - Watchdog consensus settings for failover -
failover_when_quorum_exists = on
failover_require_consensus = on

# - Watchdog cluster membership settings for quorum computation -
wd_remove_shutdown_nodes = off

# - Lifecheck Setting -
wd_lifecheck_method = 'heartbeat'
wd_interval = 3

# -- heartbeat mode --
heartbeat_hostname0 = 'funleashpgdb01'
heartbeat_port0 = 9999
heartbeat_device0 = ''
heartbeat_hostname1 = 'funleashpgdb02'
heartbeat_port1 = 9999
heartbeat_device1 = ''
heartbeat_hostname2 = 'funleashpgdb03'
heartbeat_port2 = 9999
heartbeat_device2 = ''
wd_heartbeat_keepalive = 2
wd_heartbeat_deadtime = 3

backend_hostname0 = 'funleashpgdb01'
backend_port0 = 5432
backend_weight0 = 1
backend_data_directory0 = '/data/postgresql/15/main/data'
backend_flag0 = 'ALLOW_TO_FAILOVER'
backend_application_name0 = 'funleashpgdb01'

backend_hostname1 = 'funleashpgdb02'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/data/postgresql/15/main/data'
backend_flag1 = 'ALLOW_TO_FAILOVER'
backend_application_name1 = 'funleashpgdb02'

backend_hostname2 = 'funleashpgdb03'
backend_port2 = 5432
backend_weight2 = 1
backend_data_directory2 = '/data/postgresql/15/main/data'
backend_flag2 = 'ALLOW_TO_FAILOVER'
backend_application_name2 = 'funleashpgdb03'


#------------------------------------------------------------------------------
# OTHERS
#------------------------------------------------------------------------------

relcache_expire = 0
relcache_size = 256
relcache_query_target = load_balance_node

#------------------------------------------------------------------------------
# IN MEMORY QUERY MEMORY CACHE
#------------------------------------------------------------------------------
# https://www.pgpool.net/docs/latest/en/html/runtime-in-memory-query-cache.html

memory_cache_enabled = on
memqcache_total_size = 256MB
memqcache_max_num_cache = 2796202
memqcache_cache_block_size = 2638400
memqcache_maxcache = 1638400
memqcache_oiddir = '/var/log/pgpool/oiddir'
memqcache_auto_cache_invalidation = on


```

</details>


#### 15. pgpool configuration files: pool_hba.conf (Every Node)

There is a directive in the pgpool.conf file for pool_hba.conf. It is "enable_pool_hba" which is off by default. We need this feature and want to use it. Thus, we have switched it to on in the pgpool.conf file. It has a similar functionality to pg_hba.conf for pgpool proxy.

The following is a sample of this file.

```shell
sudo -u postgres truncate -s 0 /etc/pgpool2/pool_hba.conf
sudo -u postgres vi /etc/pgpool2/pool_hba.conf
```

Copy the contents of the following file inside vim. Perform the modifications of your choice if you
 deem necessary:


```conf
# pgpool Client Authentication Configuration File
# ===============================================
#
# The format rule in this file follows the rules in the PostgreSQL
# Administrator's Guide. Refer to chapter "Client Authentication" for a
# complete description.  A short synopsis follows.
#
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which user names they can use, which databases they
# can access.  Records take one of these forms:
#
# local      DATABASE  USER  METHOD  [OPTION]
# host       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostssl    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnossl  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
#
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type: "local" is a Unix-domain
# socket, "host" is either a plain or SSL-encrypted TCP/IP socket.
# "hostssl" is an SSL-encrypted TCP/IP socket, and "hostnossl" is a
# plain TCP/IP socket.
#
# DATABASE can be "all", "sameuser", a database name, or a comma-separated
# list thereof. Note that "samegroup" like in PostgreSQL's pg_hba.conf
# file is not supported, since pgpool does not know which group a user
# belongs to. Also note that the database specified here may not exist in
# the backend PostgreSQL. pgpool will authenticate based on the database's
# name, not based on whether it exists or not.
#
# USER can be "all", a user name, or a comma-separated list thereof.  In
# both the DATABASE and USER fields you can also write a file name prefixed
# with "@" to include names from a separate file. Note that a group name
# prefixed with "+" like in PostgreSQL's pg_hba.conf file is not supported
# because of the same reason as "samegroup" token. Also note that a user
# name specified here may not exist in the backend PostgreSQL. pgpool will
# authenticate based on the user's name, not based on whether he/she exists.
#
# CIDR-ADDRESS specifies the set of hosts the record matches.
# It is made up of an IP address and a CIDR mask that is an integer
# (between 0 and 32 (IPv4) that specifies the number of significant bits in
# the mask.  Alternatively, you can write an IP address and netmask in
# separate columns to specify the set of hosts.
#
# METHOD can be "trust", "reject", "md5" , "scram-sha-256" or "pam".
# Note that "pam" sends passwords in clear text.
#
# OPTION is the name of the PAM service. Default service name is "pgpool"
#
# Database and user names containing spaces, commas, quotes and other special
# characters must be quoted. Quoting one of the keywords "all" or "sameuser"
# makes the name lose its special character, and just match a database or
# username with that name.
#
# This file is read on pgpool startup.  If you edit the file on a running
# system, you have to restart the pgpool  for the changes to take effect.

# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records. In that case you will also need to make pgpool listen
# on a non-local interface via the listen_addresses configuration parameter.
#

# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD

# "local" is for Unix domain socket connections only
local   all         all                               scram-sha-256
# IPv4 local connections:
host    all             all             172.23.124.0/24         scram-sha-256
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

host    all             all             0.0.0.0/0               md5
host    replication     all             0.0.0.0/0               md5


```


On Ubuntu, heartbeat port appears to be glitchy and sometimes will not open. In such case, pgpool will send the signal to 9999 port instead automatically, that's why I have directly assigned the 9999 port to heartbeat instead of 9694.

#### 16. Setup passwordless ssh (Every Node)

For the scripts' execution, some commands have to execute on other replicas using passwordless ssh. Thus, we need to set it up on **all the nodes**. According to our configurations, the scripts and pgpool itself are run using the postgres user. Therefore, we set passwordless ssh for this user. 

We must know that the private key and authorized_keys files **must** be exclusive to the current user for read/write permissions. So, we make sure that they have the mode 0600. 

They are also placed under .ssh directory in the user's home directory. If .ssh does not exist, we have to create it first:

```shell
sudo -u postgres mkdir -p ~postgres/.ssh
```

The file name for private and public key files conventionally includes id_rsa_pgpool. We do that using `ssh-keygen` command:

```shell
sudo -u postgres ssh-keygen -f ~postgres/.ssh/id_rsa_pgpool -t rsa
```

We choose no passphrase. Than means we press enter twice without entering any password.

![1721821699123](image/PartII/1721821699123.png)

The public and private key files are created. Next, copy the public key to the remote server:

The following must run with a postgres' user subshell. Thus we use "sh -c"

```shell
sudo -u postgres sh -c 'ssh-copy-id -i ~postgres/.ssh/id_rsa_pgpool.pub funleashpgdb02'
```

Finally, test if an ssh connection can be estabilished with funleashpgdb02 without entering a password.

```shell
sudo -u postgres sh -c 'ssh -i ~postgres/.ssh/id_rsa_pgpool funleashpgdb02'
```

Do this for all the nodes, i.e. Every Node must be able to connect to any node (including itself) using ssh (postgres ----> postgres user). 

#### Create extension on the primary server's (1st node) template1 and postgres databases
You must install and create the extensions in each database where you plan to use pgPool-II.
 This shall be done on the 1st node which we set it as our primary server at the initial Installation
 and configuration. When recovering the other nodes from the 1st node, all primary node's data including 
 these extensions will be transferred to the other nodes. 
 
To ensure that all extensions are available for future databases, you can add the extensions to the
 template1 database.

```pgsql
\c postgres
CREATE EXTENSION pgpool_recovery;
CREATE EXTENSION pgpool_adm;

\c template1
CREATE EXTENSION pgpool_recovery;
CREATE EXTENSION pgpool_adm;
```

#### Modifying the serivce file for pgPool (Not recommended for production) (Every Node)
The following service modification to pgpool is for development and test purposes and
 is not recommended for a production environment. Yet, some may choose to do so.

The pgpool_status file plays a crucial role in Pgpool-II's operation as it records 
the status of backend PostgreSQL servers.

Problems that might occur in the abscence of the pgpool_status file:
 
1. data inconsistency and discrepancy especially in scenarios where a backend might stop unexpectedly and Pgpool executes a failover procedure
2. It says wether the node is up or down, and is retained across Pgpool-II restarts
3. issues like a split-brain condition, where multiple primary servers exist.

The OPTS="-D -n" configuration is used to configure environment variables and startup options for Pgpool-II.
 Placing a line in this file sets a specific behavior for the Pgpool-II service when it starts.
 The -D option is for testing purpose only for developers and you should not use it
 for other purposes. If pgpool_status is accidentally removed, Pgpool-II may go into
 split-brain (there are multiple primary servers exist).
 The line OPTS="-D" to /etc/sysconfig/pgpool (RHEL) or pgpool.conf or service file on
 Ubuntu, tells Pgpool-II to ignore the pgpool_status file at startup,
 which normally contains the backend status (up/down). This option can be useful when
 you don't want Pgpool-II to resume the previous state
 of the backend nodes. The -n option instructs Pgpool-II to not run as a daemon
 system file which is present in the systemd service file by default and is mandatory there.
 
The alternatives are either user Environment directive or ExecStart:

```shell
sudo systemctl edit pgpool2
```

The following are alternatives for the pgPool's service file's override:

1. Alternative 1:

```shell
[Service]
ExecStart=		# This line makes the main service file's ExecStart directive ineffective. This is mandatory
				# because for this Type of service, multiple ExecStart tags are not permitted.

ExecStart=/usr/sbin/pgpool -D -n
```

2. Alternative 2:

```shell
[Service]
Environment="PGPOOL_OPTS=-D -n"

```

Next:

```shell
sudo systemctl daemon-reload
sudo systemctl restart pgpool2
```


# [Next: Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)

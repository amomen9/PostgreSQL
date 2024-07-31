&nbsp;Doc parts:

* [Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)
* [Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)
* [Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)
* [Part IV: fix some glitches for Ubuntu](./Part%20IV%20fix%20some%20glitches%20for%20Ubuntu.md)
* [Part V: pgpool command, pcp, pgpool admin commands.md ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)
* [Part VI: Simulations, tests, notes.md ](./Part%20VI%20Simulations%2C%20tests%2C%20notes.md)


# PGPOOL (Ubuntu) Part V

### pgpool command, pcp commands, pgpool admin commands

#### pgpool:

```shell
pgpool --help
```

![Screenshot_41](image/Part%20V/Screenshot_41.png)

This command is mostly used to reload, stop, and start pgpool. It bypasses systemd. It is also used to start
 pgpool service in the pgpool's systemd service file. Just like other applications, using it for the service
 user (here postgres) does not need root priviledges. We already know the important flags `-D, -n, -a, -f, -k, -F`
 `-x` and `-d` are for debug aid, and shutdown modes are similar to that of PostgreSQL because the proxy's nature
 is similar to the direct connections with the database clusters.

#### pcp commans:

pcp stands for "Pgpool-II Control Program" commands.
 pcp cli tools can either be used by installing pgpool2 package or by installing its python module like below and running its commands using python. We will use shell commands anyways.
 
install in python:

`pip install pypcp`



These are the pcp commands and their bried explainations. We already know some info like authentication about them from the previous sections:

**Reference:**

[ http://192.168.171.71/docs/pgpool2/pcp-commands.html ](http://192.168.171.71/docs/pgpool2/pcp-commands.html)

| <div align="center"> pcp commands </div> |
|:----------------:|
| <div align="left"> •  **pcp_attach_node:** Attaches a given node to Pgpool-II.<br/><br/> •  **pcp_detach_node:** Detaches the given node from Pgpool-II.<br/><br/> •  **pcp_node_count:** Displays the total number of database nodes.<br/><br/> •  **pcp_node_info:** Displays information on the given node ID.<br/><br/> •  **pcp_health_check_stats:** Displays health check statistics data on the given node ID.<br/><br/> •  **pcp_watchdog_info:** Displays the watchdog status of Pgpool-II.<br/><br/> •  **pcp_proc_count:** Displays the list of Pgpool-II children process IDs.<br/><br/> •  **pcp_proc_info:** Displays information on the given Pgpool-II child process ID.<br/><br/> •  **pcp_pool_status:** Displays the parameter values as defined in pgpool.conf.<br/><br/> •  **pcp_promote_node:** Promotes the given node as new main to Pgpool-II.<br/><br/> •  **pcp_stop_pgpool:** Terminates the Pgpool-II process.<br/><br/> •  **pcp_reload_config:** Reloads the Pgpool-II config file.<br/><br/> •  **pcp_recovery_node:** Attaches the given backend node with recovery. </div> |

The pcp commands also have SQL statements. They are dependent to these statements, because when they execute the SQL statements are also executed behind the scenes. That is why creating their extension is mandatory.
 These are some of these statements which are added by creating the pgpool_adm extension:

```pgsql 
function pcp_attach_node(integer,text)
function pcp_attach_node(integer,text,integer,text,text)
function pcp_detach_node(integer,boolean,text)
function pcp_detach_node(integer,boolean,text,integer,text,text)
function pcp_health_check_stats(integer,text)
function pcp_health_check_stats(integer,text,integer,text,text)
function pcp_node_count(text)
function pcp_node_count(text,integer,text,text)
function pcp_node_info(integer,text)
function pcp_node_info(integer,text,integer,text,text)
function pcp_pool_status(text)
function pcp_pool_status(text,integer,text,text)
```

These SQL commands are added by the pgpool_recovery extension:

```pgsql
function pgpool_recovery(text,text,text,text,integer,text,text)
function pgpool_recovery(text,text,text,text,integer,text)
function pgpool_recovery(text,text,text,text,integer)
function pgpool_recovery(text,text,text,text)
function pgpool_recovery(text,text,text)
function pgpool_remote_start(text,text)
function pgpool_pgctl(text,text)
function pgpool_switch_xlog(text)
```

Now, we dive into the pcp commands one by one<br/> (nearly in the importance order):
<br/>
<br/>

---
•  **pcp_node_info:** Displays information on the given node ID.
<br/>Displays the following info about one or all the nodes
<br/><br/>•  **pcp_watchdog_info:** Displays the watchdog status of Pgpool-II.
<br/>watchdog info for the nodes.
<br/><br/>•  **pcp_promote_node:** Promotes the given node as new main to Pgpool-II.
<br/>Promotes a node as the watchdog leader.
<br/><br/>•  **pcp_recovery_node:** Attaches the given backend node with recovery.
<br/>One of the most important ones to recover a node from another node (usually primary node)
<br/><br/>•  **pcp_stop_pgpool:** Terminates the Pgpool-II process.
<br/>Same as `pgpool stop`
<br/><br/>•  **pcp_reload_config:** Reloads the Pgpool-II config file.
<br/>Same as `pgpool reload` command.
<br/><br/>•  **pcp_attach_node:** Attaches a given node to Pgpool-II.
<br/>The node will be counted in the consensus and voting.
<br/><br/>•  **pcp_detach_node:** Detaches the given node from Pgpool-II.
<br/>The node will be removed from the consensus and voting.
<br/><br/>•  **pcp_node_count:** Displays the total number of database nodes.
<br/>Numer of the nodes
<br/><br/>•  **pcp_health_check_stats:** Displays health check statistics data on the given node ID.
<br/>Similar to the pcp_node_info
<br/><br/>•  **pcp_proc_count:** Displays the list of Pgpool-II children process IDs.
<br/>These processed are also observable via `ps aux` or pgpool service status
<br/><br/>•  **pcp_proc_info:** Displays information on the given Pgpool-II child process ID.
<br/><br/>•  **pcp_pool_status:** Displays the parameter values as defined in pgpool.conf.

---

#### important! 
If any configuration change for postgres is deemed necessary, here is the following approach:

1. change the configuration on the primary server
2. stop the service on the secondary nodes
3. recovery process will be carried out on the standby nodes.
4. the primary node will be stopped
5. one of the standby nodes will become the new primary.
6. recovery process will be carried out for the old primary node.


#### Some common errors:

1. If you got the following error,

pcp_recovery_node -h vip -p 9898 -U pgpool -n 1

| ERROR:  executing recovery, execution of command failed at "1st stage"<br/>DETAIL:  command:"recovery_1st_stage"|
| :-------------------------------------------------------------------------------------------------------------: |

It is likely that:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. The extensions are probably not created in the postgres and template1 databases.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Scripts do not exist in the right location, or are not executable

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c. Or any other reason that casues the SQL functions noted before to fail.

2. If you get the following error,<br/>
 the socket file is probably placed somewhere else because of the pgpool bug, or it is not
 yet been created by pgpool and you should wait a while.

`psql -p 9999`

| psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.9999" failed: No such file or directory<br/>Is the server running locally and accepting connections on that socket? |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |


# [Next: Part VI: Simulations, tests, notes ](./Part%20VI%20Simulations%2C%20tests%2C%20notes.md)

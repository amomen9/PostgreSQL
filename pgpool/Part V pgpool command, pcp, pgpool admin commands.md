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

These are the pcp commands and their bried explainations. We already know some info like authentication about them from the previous sections:


| <div align="center"> pcp commands </div> |
|:----------------:|
| <div align="left"> •  **pcp_attach_node:** Attaches a given node to Pgpool-II.<br/><br/> •  **pcp_detach_node:** Detaches the given node from Pgpool-II.<br/><br/> •  **pcp_node_count:** Displays the total number of database nodes.<br/><br/> •  **pcp_node_info:** Displays information on the given node ID.<br/><br/> •  **pcp_health_check_stats:** Displays health check statistics data on the given node ID.<br/><br/> •  **pcp_watchdog_info:** Displays the watchdog status of Pgpool-II.<br/><br/> •  **pcp_proc_count:** Displays the list of Pgpool-II children process IDs.<br/><br/> •  **pcp_proc_info:** Displays information on the given Pgpool-II child process ID.<br/><br/> •  **pcp_pool_status:** Displays the parameter values as defined in pgpool.conf.<br/><br/> •  **pcp_promote_node:** Promotes the given node as new main to Pgpool-II.<br/><br/> •  **pcp_stop_pgpool:** Terminates the Pgpool-II process.<br/><br/> •  **pcp_reload_config:** Reloads the Pgpool-II config file.<br/><br/> •  **pcp_recovery_node:** Attaches the given backend node with recovery. </div> |


# [Next: Part VI: Simulations, tests, notes ](./Part%20VI%20Simulations%2C%20tests%2C%20notes.md)

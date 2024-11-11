&nbsp;Doc parts:


* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge & Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)


# Part I: Setup PostgreSQL, Patroni, and Watchdog
**Install and Configure PostgreSQL**

**Note:**

1. PostgreSQL major version specified here is 15. However, this manual also complies with most of the pg versions in use, including 12, 13, 14, 15, 16, and most likely later versions, as well.
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

#### 4. Firewall (Every Node)

Either disable the firewall or allow the needed incoming TCP ports for it.
The needed TCP ports (If you are using the defaults) are:
PostgreSQL:
5432/tcp
etcd:
2380/tcp, 2379/tcp

These ports must be open in both local machine and infrastructure/cloud firewall for the required sources.


# [Next: Part II: Logs Purge & Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)

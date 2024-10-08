# Patroni

Here we discuss different HA solutions with Patroni. Patroni needs to come with
 a watchdog for the election and other issues that affect a highly available cluster.

Some sample watchdog solutions for the record are the following, though we discuss
 etcd solution in this document.

* Linux Kernel Watchdog (Built-in Watchdog)
	* External Watchdog Daemons

### * Setup Patroni with etcd watchdog (Ubuntu & RHEL)

For this matter, we have several steps ahead:

1. Some preminilaries
2. Install PostgreSQL on every node. Refer to PostgreSQL section to see how.
3. Install Patroni
4. Install etcd

#### Priminilaries:

Suppose that we have 3 pg nodes. The etcd watchdog can be installed on separate servers or on the same servers, and in any number of servers. It is advised that the number of etcd server be more than one to avoid the single point of failure.

The servers' IP addresses and hostnames will be as follows:


Edit /etc/hosts file to include servers' names and IP addresses for name resolution.

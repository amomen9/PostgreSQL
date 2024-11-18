&nbsp;Doc parts:

* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)
* [Part III: Evict/Add node from/to the cluster ](./Part%20III%20cluster%20Evict%2DAdd%20node.md)

# Part III: Evict/Add node from/to the cluster

### Part I: Evict:

For evict process, several configurations must change, incorporating Patroni, etcd, and vip-manager.
 but the process also includes some elaborations and delicacies in terms of the order of the actions
 you take, the Watchdog (etcd) distributed database, bringing services up and down, etc. So you must
 take into consideration that the order of the actions is important

These considerations also hold for adding a node to the cluster.

In this doc we are assuming that we want to evict Node 3 with the following specifications:

etcd node name: n3
IP: 172.23.124.73
hostname: funleashpgdb03
patroni node name: maunleash03

#### etcd configurations:

If the node to be evicted is the leader node, the a switchover must be performed first in Partroni.
 This typically also incorporates moving the etcd leader node, however, we do both to make sure everything
 is ok.

```shell
patronictl -c /etc/patroni/config.yml switchover
```

A sample of switchover is as follows:

![1731847156143](image/PartIIIclusterEvict-Addnode/1731847156143.png)

We also check the watchdog leader as I mentioned:

```shell
etcdctl endpoint status --endpoints=<etcd-endpoints>
# or
etcdctl get "/maunleashdb/17-main/leader" --prefix | tail -n +2
```

If it is the node to be evicted, we move the leader by first getting the hash ID of the nodes (endpoints), then
 entering the new leader's hash ID in `etcdctl move-leader <endpoint ID>` command:

```shell
etcdctl member list
```

![1731848085191](image/PartIIIclusterEvict-Addnode/1731848085191.png)

Now:

```shell
etcdctl move-leader <endpoint ID>
```


```shell
vi /etc/default/etcd
```

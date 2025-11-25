&nbsp;Doc parts:

* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)
* [Part III: Evict/Add node from/to the cluster ](./Part%20III%20cluster%20Evict%2DAdd%20node.md)
* [Part IV: PGBouncer](../PGBouncer/Setup%20PGBouncer.md)

# Part III: Evict/Add node from/to the cluster

## Part A: Evict:

Initial state of the cluster:

```shell
patronictl -c /etc/patroni/config.yml list
```
![1731920174389](image/PartIIIclusterEvict-Addnode/1731920174389.png)

**Figure 1**

For evict process, several configurations must change, incorporating Patroni, etcd, and vip-manager.
 but the process also includes some elaborations and delicacies in terms of the order of the actions
 you take, the Watchdog (etcd) distributed database, bringing services up and down, etc. So you must
 take into consideration that the order of the actions is important

These considerations also hold for adding a node to the cluster.

In this doc we are assuming that we want to evict Node 3 with the following specifications:

| <div align="left">etcd node name: n3<br/>IP: 172.23.124.73<br/>hostname: funleashpgdb03<br/>patroni node name: maunleash03</div> |
| :--------------------------------------------------------------------------------------------------------------------------------------------------: |

#### 1. Manual failover (if needed):

If the node to be evicted is the leader node, a switchover must be performed first in Partroni.
 This typically also incorporates moving the etcd leader node, however, we do perform a check
 to make sure that everything is ok.

```shell
patronictl -c /etc/patroni/config.yml switchover
```

A sample of switchover is as follows:

![1731847156143](image/PartIIIclusterEvict-Addnode/1731847156143.png)

**Figure 2**

We also check the watchdog leader as I mentioned:

```shell
etcdctl endpoint status --endpoints=<etcd-endpoints>
```

If it is the node to be evicted, we move the leader by first getting the hash ID of the nodes (endpoints), then
 entering the new leader's hash ID in `etcdctl move-leader <endpoint ID> command:

To get hash ID of the nodes:

```shell
etcdctl member list
# or
etcdctl endpoint status --endpoints=<etcd-endpoints>
```

![1731848085191](image/PartIIIclusterEvict-Addnode/1731848085191.png)

**Figure 3**

Now:

```shell
etcdctl move-leader <endpoint ID>
```

A sample of the watchdog leader move process is as follows:

![1731915794398](image/PartIIIclusterEvict-Addnode/1731915794398.png)

**Figure 4**

### Patroni:

#### 2. Stop and disable Patroni service <ins>on the third (evict) node</ins>:

```shell
systemctl disable --now patroni
```

After some moments, the result for 
```shell
patronictl -c /etc/patroni/config.yml list
```

will be without the evict node like below:

![1731915794398](image/PartIIIclusterEvict-Addnode/Screenshot_108.png)

**Figure 5**

#### 3. Modify Patroni configurations (for Nodes Remaining in the cluster):

```shell
vi /etc/patroni/config.yml
```

Remove the entry in the etcd/etcd3 hosts configuration for the evict node:

![1731919442449](image/PartIIIclusterEvict-Addnode/1731919442449.png)

**Figure 6**

#### 4. Reload Patroni configurations (for Nodes Remaining in the cluster):

Reload the Patroni service, instead of restarting, to avoid bringing down PostgreSQL or cause a failover.

```shell
systemctl reload patroni
```

### etcd:

#### 5. Modify etcd configurations (for Nodes Remaining in the cluster):

```shell
vi /etc/default/etcd
```

Remove the node to be evicted from the etcd configuration file on the nodes that are remaining in the cluster
 from ETCD_INITIAL_CLUSTER env variable.

![1731916419854](image/PartIIIclusterEvict-Addnode/1731916419854.png)

**Figure 7**

#### 6. Remove the evict node from etcd (on any of the Nodes Remaining in the cluster):

Stop the etcd service on the evict node:

```shell
systemctl disable --now etcd
```

|<div align="left">Note:<br/>For reassurance measures, we remove the etcd data on the third node like below. This is to avoid conflicts should we be willing to return it to this cluster or add it to another cluster at a later time. The data on this node will not be needed anymore anyways:<br/><br/>rm -rf /var/lib/etcd/*<br/>echo > /etc/default/etcd</div>|
|:-:|

Now that the third node's etcd service is gone for whatever reason, the etcd service on the 1st and 2nd nodes shows health check warning like below:

```shell
systemctl status etcd
```

![1731915794398](image/PartIIIclusterEvict-Addnode/Screenshot_110.png)

**Figure 8**

Again get the endpoint hash ID with:

```shell
etcdctl member list
```

Remove the evict node with its hash ID:

```shell
etcdctl member remove <member-ID>
```

Sample:

![1731915794398](image/PartIIIclusterEvict-Addnode/Screenshot_109.png)

**Figure 9**

Check etcd service status on one of the remaining nodes to see of there is no health check warning:

```shell
systemctl status etcd
```

Sample result:

![1731915794398](image/PartIIIclusterEvict-Addnode/Screenshot_107.png)

**Figure 10**

---

## Part B: Add:

Suppose these are the specifications of the new node:

| <div align="left">etcd node name: n4<br/>IP: 172.23.124.74<br/>hostname: funleashpgdb04<br/>patroni node name: maunleash04</div> |
| :--------------------------------------------------------------------------------------------------------------------------------------------------: |

### etcd

#### 1. Add member passively:

On one of the existing nodes, execute the following command: 

```shell
etcdctl member add n4 --peer-urls=http://172.23.124.74:2380
```

Sample output:

![1731915794398](image/PartIIIclusterEvict-Addnode/Screenshot_111.png)

**Figure 11**

As you can see, this command outputs the below mandatory configurations that you need to apply to the new node
 in its `/etc/default/etcd` file to help you to do so:

![1731915794399](image/PartIIIclusterEvict-Addnode/Screenshot_112.png) 

**Figure 12**

* Note!<br/>As you can see the ETCD_INITIAL_CLUSTER_STATE must be set to `existing` here and not `new`.

#### 2. Install and config etcd on the new node

Setup etcd like [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md) of
 the documentation on the new node. Include the configs of `Figure 12` command output, having all of the nodes in the new node's
 `/etc/default/etcd` file.

#### 3. Start etcd service on the new node

Start and enable the etcd service on the new node if not already started:

```shell
systemctl enable --now etcd
```

### Patroni

#### 4. Modify Patroni configurations (for Nodes existing in the cluster):

Add the 3rd node to the `hosts` directive under `etcd3` to the patroni config file (`/etc/patroni/config.yml`)

![1731919442449](image/PartIIIclusterEvict-Addnode/1731919442449.png)

**Figure 13**

#### 5. Restart Paroni service (for Nodes existing in the cluster):

Restart the Patroni services with the necessary failover measures.

#### 6. Install and config Patroni on the new node

Setup Patroni like [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md) of
 the documentation on the new node. Include all of the nodes in its `/etc/patroni/config.yml` file.
 
#### 7. Start Patroni on the new node

Start and enable Paroni service on the new node.

```shell
systemctl enable --now patroni
```

# [Next: Part IV: PGBouncer](../PGBouncer/Setup%20PGBouncer.md)
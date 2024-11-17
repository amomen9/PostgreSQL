&nbsp;Doc parts:

* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)
* [Part III: Evict/Add node from/to the cluster ](./Part%20III%20cluster%20Evict%2DAdd%20node.md)

# Part III: Evict/Add node from/to the cluster

#### Part I: Evict:

For evict process, several configurations must change, incorporating Patroni, etcd, and vip-manager.
 but the process also includes some elaborations and delicacies in terms of the order of the actions
 you take, the Watchdog (etcd) distributed database, bringing services up and down, etc. So you must
 take into consideration that the order of the actions is important
 
These considerations also hold for adding a node to the cluster.




 

# Add a PostgreSQL Database Cluster to the Redgate SQL Monitor for Monitoring

* References and further details:

1. [Summary of firewall requirements](https://documentation.red-gate.com/monitor14/summary-of-firewall-requirements-239667770.html)
2. [Connecting to a Linux Machine](https://documentation.red-gate.com/monitor14/connecting-to-a-linux-machine-239667808.html)
3. [Preparing PostgreSQL for monitoring](https://documentation.red-gate.com/monitor14/preparing-postgresql-for-monitoring-239667737.html)
4. [Enabling query plan monitoring](https://documentation.red-gate.com/monitor14/enabling-query-plan-monitoring-239667738.html)

<br/>

---

<br/>

### Preparing PostgreSQL for monitoring

#### 1. Firewall Requirements

The PostgreSQL and SSH ports on the target machine must be visible  

#### 1. Perform the necessary modifications in PostgreSQL configurations 

We need the following configurations in the postgresql.conf to be in effect:

```conf
shared_preload_libraries = 'pg_stat_statements' # (change requires restart)
log_destination = 'csvlog'
logging_collector = on
track_io_timing = on
```

The first directive forces us to perform a pg service restart. We do it with the corresponding necessary
 considerations. For instance, on a cluster with Patroni, we execute the following and do
 nothing to PostgreSQL service itself directly:
 
```shell
systemctl restart patroni.service
```
&nbsp;Doc parts:


* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge & Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)


# Part II: Logs Purge & Retention


### Types of Logs and History Records:

##### 1. PostgreSQL

The PostgreSQL Log files Retention Policiy is set through Log settings in PostgreSQL configurations with
 the following directives:

```conf
log_filename = 'postgresql-15-main-%A.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_truncate_on_rotation = on
```

##### 2. etcd

etcd Logs are classified in the following groups:

a- WAL files:

Configs: We set the following environment variable(s) in the /etc/default/etcd file for the
 etcd configurations to take effect

```shell
ETCD_MAX_WALS=5
```

b- snapshot files:

Configs: We set the following environment variable(s) in the /etc/default/etcd file for the
 etcd configurations to take effect

```shell
ETCD_MAX_SNAPSHOTS=5
```

c- history purge:

The revision history needs purging using the following variables:
```shell
ETCD_AUTO_COMPACTION_RETENTION=168
# 7 days
ETCD_AUTO_COMPACTION_MODE=periodic
```
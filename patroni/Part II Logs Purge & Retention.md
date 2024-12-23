&nbsp;Doc parts:


* [Part I: Setup PostgreSQL, Patroni, and Watchdog ](./Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md)
* [Part II: Logs Purge &amp; Retention ](./Part%20II%20Logs%20Purge%20%26%20Retention.md)
* [Part III: Evict/Add node from/to the cluster ](./Part%20III%20cluster%20Evict%2DAdd%20node.md)


# Part II: Logs Purge & Retention


### Types of Logs and History Records:

##### 1. PostgreSQL

The PostgreSQL Log files Retention Policiy is set through Log settings in PostgreSQL configurations with
 the following directives:

```conf
log_filename = 'postgresql-15-main-%A.log'
log_rotation_age = 1d
log_rotation_size = 1024MB
log_truncate_on_rotation = on
```

The above configurations mean that the log files rotate every day, we will have a log history of at most 1 week
 ,and every newly created log will truncate the previous log file with the same name's contents (from the 
 previous week). %A is the format specifier for the weekdays like "Wednesday".

##### 2. etcd

For more info and reference, refer to the following link on the official website:

[ https://etcd.io/docs/v3.4/op-guide/configuration/ ](https://etcd.io/docs/v3.4/op-guide/configuration/)

etcd files to be considered for purging are classified in the following groups:

<ins>a) WAL files:</ins>

Configs: We set the following environment variable(s) in the /etc/default/etcd file for the
 etcd configurations to take effect

```shell
ETCD_MAX_WALS=5
```

<ins>b) snapshot files:</ins>

Configs: We set the following environment variable(s) in the /etc/default/etcd file for the
 etcd configurations to take effect

```shell
ETCD_SNAPSHOT_COUNT=100000
ETCD_MAX_SNAPSHOTS=5
```

<ins>c) history purge:</ins>

First we
The revision history needs purging using the following variables:
```shell
ETCD_AUTO_COMPACTION_RETENTION=168
# 7 days
ETCD_AUTO_COMPACTION_MODE=periodic
```

##### 3. Patroni

For more info and reference, refer to the following link on the official website:

[ https://patroni.readthedocs.io/en/latest/yaml_configuration.html ](https://patroni.readthedocs.io/en/latest/yaml_configuration.html)

```yaml
log:
  traceback_level: INFO
  level: INFO
  dir: /var/log/patroni/
  file_num: 6
  file_size: 25165824
  mode: 0644
```

These configs will create 6 rollover files, each of which with 24 MB size at most, and a log level of info.

# [Next: Part III: Evict/Add node from/to the cluster ](./Part%20III%20cluster%20Evict%2DAdd%20node.md)

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
log_rotation_size = 1024MB
log_truncate_on_rotation = on
```

The above configurations mean that the log files rotate every day, we will have a log history of at most 1 week
 ,and every newly created log will truncate the previous log file with the same name's contents (from the 
 previous week). %A is the format specifies for the weekdays like "Wednesday".

##### 2. etcd

For more info and reference, refer to the following link on the official website:

[ https://etcd.io/docs/v3.4/op-guide/configuration/ ](https://etcd.io/docs/v3.4/op-guide/configuration/)

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
ETCD_SNAPSHOT_COUNT=100000
ETCD_MAX_SNAPSHOTS=5
```

c- history purge:

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
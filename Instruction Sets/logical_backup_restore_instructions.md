# Logical Backup and Restore (SQL Dump)

This runbook shows a simple logical backup using `pg_dumpall` and restore using `psql`.

---

## 1) Dump all databases

Local host example:

```shell
pg_dumpall -U postgres -h localhost -p 5432 > all_databases.sql
```

Remote example:

```shell
pg_dumpall -U postgres -h 172.23.174.123 -p 30361 > all_databases.sql
```

---

## 2) Restore

```shell
psql -U postgres -h localhost -p 5432 -f all_databases.sql
```

Notes:
- `pg_dumpall` dumps roles and globals too; restoring into an existing cluster may fail if objects already exist.
- For selective backups, use `pg_dump` per database instead.

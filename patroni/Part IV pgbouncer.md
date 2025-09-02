
# Add pgbouncer connection pooler for PostgreSQL

1. Install pgbouncer

```shell
sudo apt-get update
sudo apt-get install pgbouncer -y
```

2. Modify pgbouncer conf and add a sample configuration like below
 for every node
 
```shell
truncate -s 0 /etc/pgbouncer/pgbouncer.ini 
```
```shell
vi /etc/pgbouncer/pgbouncer.ini 
```

```ini
; pgbouncer.ini
[databases]
<db1> = host=127.0.0.1 port=5432 user=payam password=<pass> client_encoding=UNICODE datestyle=ISO
<db2> = host=127.0.0.1 port=5432 user=postgres password=<pass> client_encoding=UNICODE datestyle=ISO
<db3> = host=127.0.0.1 port=5432 user=postgres password=<pass> client_encoding=UNICODE datestyle=ISO

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20

```

**Sample**

```ini
[databases]
postgres = host=127.0.0.1 port=5432 user=postgres password=postgrespass client_encoding=UNICODE datestyle=ISO

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 3000
default_pool_size = 20
unix_socket_dir = /var/run/postgresql
```


3. Populate `/etc/pgbouncer/userlist.txt` file

```shell
vi /etc/pgbouncer/userlist.txt
```
```text
"user1" "pass"
"user2" "pass"
```

The pass can be in any format. It does not need to be database cluster user/password, it is
 for pgbouncer authentication, but the hashing algorithm is the same. If you need it to be
 the same as the database cluster, for the hashed password, you can query `pg_authid` catalog
 table.

```sql
SELECT rolpassword FROM pg_authid WHERE rolname='Your User'
```
 
4. restart pgbouncer service

```bash
systemctl enable pgbouncer.service
systemctl restart pgbouncer.service
```

5. Connect to postgres database cluster using `<server name/address>`, `<server pgbouncer port>`, `<pgbouncer user>`
 , and `<pgbouncer pass>`
 
 
**Note!**
If you plan to install `prometheus-pgbouncer-exporter` too for pgbouncer monitoring, you will need to adjust the
 location for pgbouncer Unix domain socket file. The default location is /tmp. However, `prometheus-pgbouncer-exporter`
 expects it to be /var/run/postgresql beside PostgreSQL main socket file.
 
You can do this by adding the following line to the pgbouncer configuration:

```ini
[pgbouncer]
unix_socket_dir = /var/run/postgresql
```

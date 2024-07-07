sudo mkdir -p /var/postgresql/pg-local-full-backup/systemd/ && \
sudo mkdir -p /var/postgresql/pg-wal-archive/ && \
sudo chown -R postgres:postgres /var/postgresql

mkdir -p /backup/postgresql/pg-wal-backup-archive/systemd/$(hostname)/

# enter the name of the servers and "vip" in /etc/hosts regardless of if
# the cluster is a single node or has several nodes
<ip address> server1
<ip address> server2
.
.
.

<ip address> vip
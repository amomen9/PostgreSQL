directories to create:
mkdir -p /var/log/patroni
chown -R postgres:postgres /var/log/patroni

mkdir -p /archive/postgresql/pg-wal-archive/
mkdir -p /archive/postgresql/pg-local-full-backup/systemd/
chown -R postgres:postgres /archive/postgresql






- disable/manage firewall
default required ports:
pg: 5432,
etcd: 2379, 2380
systemctl disable --now ufw
systemctl mask ufw

- Install PG

sudo apt install -y postgresql-15 postgresql-15-repack postgresql-15-plpgsql-check \
postgresql-15-cron postgresql-15-pgaudit postgresql-15-show-plans postgresql-doc-15 \
postgresql-contrib-15 postgresql-15-plprofiler plprofiler postgresql-15-preprepare iputils-arping

- If the directory /var/lib/postgresql existed (for example as a mount point) before the first time postgresql
 was installed, running the following is mandatory
chown -R postgres:postgres /var/lib/postgresql


- Install Patroni and Stop and disable it if it's running

apt install -y patroni
systemctl disable --now patroni

- put patroni config files in place (config.yml disable dcs.yml)
mv /etc/patroni/dcs.yml /etc/patroni/dcs.yml.bak
vi /etc/patroni/config.yml
chown -R postgres:postgres /etc/patroni


- Install etcd and Stop and disable it if it's running
apt install -y etcd
systemctl disable --now etcd

- If the directory /var/lib/etcd existed (for example as a mount point) before the first time etcd
 was installed, running the following is mandatory
chown -R etcd:etcd /var/lib/etcd



- Make the etcd API version 3 global by putting it inside /etc/profile
vi /etc/profile
export ETCDCTL_API=3

- make it effective for the current session too
source /etc/profile

- Edit the /etc/default/etcd file
ETCD_NAME=n1
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://172.23.124.71:2380"
ETCD_LISTEN_CLIENT_URLS="http://172.23.124.71:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.23.124.71:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://172.23.124.71:2379"
ETCD_INITIAL_CLUSTER="n1=http://172.23.124.71:2380,n2=http://172.23.124.72:2380,n3=http://172.23.124.73:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-pg"


- Make sure postgresql service is functional on the first node, connect to it and alter or
 create necessary users and their permissions. Check the changes:
alter user postgres password 'i1AGdhtr86DeROdIAM';
create user replicator replication password 'i1AGdhtr86DeROdIAM';
select * from pg_user;

- stop and disable and mask postgresql systemd service on every node:
systemctl disable --now postgresql@15-main.service
systemctl mask postgresql@.service postgresql.service


- delete data directory contents on the 2nd and 3rd nodes only
rm -rf /var/lib/postgresql/15/main/*
---------------

- enable and start etcd service
systemctl enable --now etcd

- enable and start patroni service. We want to start patroni for the first time. Thus, we want
 to make sure that postgresql is not running. We do these by executing the following commands
pg_ctlcluster 15 main stop -m immediate
systemctl enable --now patroni

- install and setup vip-manager
apt install -y vip-manager2



- Config VIP Manager. Modify the service file in override to read from the config file instead of the environment
variables (This is optional). Write the following in the service override file:

systemctl edit vip-manager

# /etc/systemd/system/vip-manager.service.d/override.conf
[Service]

ExecStart=
ExecStart=/usr/bin/vip-manager --config=/etc/default/vip-manager.yml

- Reload daemon
systemctl daemon-reload


- Config VIP Manager. Set the following directives and others like below. 
trigger-key: "/maunleashdb/15-main/leader"
trigger-value: "maunleash01"

- Put the vip-manager.yml inside /etc/default/ directory on every node. The trigger-value must be specific to every node.

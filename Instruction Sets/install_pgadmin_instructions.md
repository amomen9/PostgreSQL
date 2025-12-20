# Install pgAdmin 4

This runbook provides installation steps for pgAdmin 4 on common Linux distributions.

---

## Ubuntu 24.04 (Web mode)

```shell
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
  | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
  > /etc/apt/sources.list.d/pgadmin4.list'

sudo apt update
sudo apt install -y pgadmin4-web

# Initial configuration
sudo /usr/pgadmin4/bin/setup-web.sh
```

---

## RHEL / Rocky / CentOS (YUM/DNF)

1) Remove old pgAdmin repo package if present:

```shell
sudo rpm -e pgadmin4-redhat-repo
```

2) Add pgAdmin repo:

```shell
sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm
```

3) Install pgAdmin:

```shell
# Install both desktop and web modes
sudo yum install -y pgadmin4

# Desktop-only
# sudo yum install -y pgadmin4-desktop

# Web-only
# sudo yum install -y pgadmin4-web
```

# Install PgpoolAdmin on Ubuntu

This runbook installs PgpoolAdmin (web UI for Pgpool-II) on Ubuntu using Apache + PHP.

> PgpoolAdmin currently requires PHP `< 8`. This runbook uses PHP 7.4.

---

## Prerequisites

- Pgpool-II installed and working.
- Apache2 installed.
- A supported PHP version (5.6.0 ≤ PHP < 8).

---

## 1) Install Apache

```shell
sudo apt update
sudo apt install -y apache2
```

---

## 2) Install PHP 7.4 (remove PHP 8+ if present)

```shell
sudo apt remove -y --purge 'php8.*' php-pgsql php-mbstring
sudo apt autoremove -y
```

Install Ondřej Surý PPA for older PHP versions:

```shell
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php7.4
```

---

## 3) Ensure Pgpool binaries are executable

```shell
sudo chmod 755 /usr/sbin/pgpool
sudo chmod 755 /usr/sbin/pcp_*
```

---

## 4) Configure a PgpoolAdmin PCP user in `pcp.conf`

Generate password hash:

```shell
pg_md5 <password_string>
```

Example:

```shell
echo "pgpoolAdmin:$(pg_md5 pgpoolAdmin)" | sudo tee -a /etc/pgpool2/pcp.conf
```

---

## 5) Deploy PgpoolAdmin

1. Download from the official site:
- https://pgpool.net/mediawiki/index.php/Downloads

2. Extract and move into Apache doc root (example version `4.2.0`):

```shell
mv pgpoolAdmin-4.2.0.tar.gz /tmp
cd /tmp
tar xzvf pgpoolAdmin-4.2.0.tar.gz
sudo mv pgpoolAdmin-4.2.0 /var/www/html/pgpoolAdmin
sudo chown -R postgres:postgres /var/www
```

---

## 6) Enable PHP modules PgpoolAdmin needs

Use PgpoolAdmin’s PHP info page to confirm:
- `Multibyte Support`
- `PostgreSQL Support`

URL:
- `http://<host>/pgpoolAdmin/install/phpinfo.php`

Install modules:

```shell
sudo apt-get install -y php7.4-mbstring php7.4-pgsql
sudo systemctl restart apache2
```

If multibyte is still disabled, enable it and restart Apache:

```shell
cd /etc/php/7.4/apache2
sudo find /etc/php/7.4/apache2 -type f -exec sed -i 's/;zend.multibyte = Off/zend.multibyte = On/g' {} +
sudo systemctl restart apache2
```

---

## 7) Permissions required by PgpoolAdmin

Create template cache dir:

```shell
cd /var/www/html/pgpoolAdmin
sudo mkdir -p templates_c
sudo chmod 777 templates_c
```

Ensure PgpoolAdmin can read/write its config:

```shell
cd /var/www/html/pgpoolAdmin/conf
sudo chmod 644 pgmgt.conf.php
```

Ensure Apache user can read Pgpool configuration files.

Typical safe approach is to keep Apache as `www-data` and adjust group permissions.
If you intentionally run Apache as `postgres` (not generally recommended), ensure you understand the security tradeoff.

---

## 8) Run the web installer

Open:
- `http://<host>/pgpoolAdmin/install/index.php`

Confirm these paths (Ubuntu defaults):
- `pgpool.conf`: `/etc/pgpool2/pgpool.conf`
- `pcp.conf`: `/etc/pgpool2/pcp.conf`
- Pgpool command: `/usr/sbin/pgpool`
- PCP directory: `/usr/sbin`

After successful setup, remove the installer directory:

```shell
sudo rm -rf /var/www/html/pgpoolAdmin/install
```

---

## Troubleshooting

```shell
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/php_errors.log
```

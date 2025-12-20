# Install phpPgAdmin on Ubuntu

This runbook installs phpPgAdmin and exposes it through Apache.

---

## 1) Install package

```shell
sudo apt update
sudo apt install -y phppgadmin
```

---

## 2) Permissions (typical)

```shell
sudo chown -R www-data:www-data /usr/share/phppgadmin
sudo chmod -R 755 /usr/share/phppgadmin
```

---

## 3) Configure Apache alias

Edit the default site config:

```shell
sudo vi /etc/apache2/sites-available/000-default.conf
```

Add:

```apache
Alias /phpPgAdmin /usr/share/phpPgAdmin

<Directory /usr/share/phppgadmin>
    Options FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

Restart Apache:

```shell
sudo systemctl restart apache2
```

---

## Troubleshooting (only if needed)

If you’re blocked by system security tools (use with caution):

```shell
# SELinux (RHEL-like)
sudo setenforce 0

# AppArmor (Ubuntu)
sudo systemctl stop apparmor.service

# Allow HTTP in firewall (Ubuntu)
sudo ufw allow 80/tcp
sudo ufw reload
```

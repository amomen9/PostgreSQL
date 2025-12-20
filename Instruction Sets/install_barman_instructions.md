# Install Barman on Ubuntu

This runbook installs Barman packages from Ubuntu repositories.

---

## Install packages

```shell
sudo apt update
sudo apt install -y barman barman-cli python3-barman
```

Next steps (not covered here):
- Configure SSH key-based access to PostgreSQL servers.
- Configure `barman.conf` and per-server configuration.
- Ensure `wal_level`, `archive_mode`, and `archive_command` are compatible with your backup strategy.

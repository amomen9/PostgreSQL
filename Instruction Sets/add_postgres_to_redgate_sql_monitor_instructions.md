# Add a PostgreSQL Instance to Redgate SQL Monitor (SSH-based collection)

This runbook captures the initial SSH key setup typically needed when a monitoring tool connects to a PostgreSQL host.

> Redgate SQL Monitor configuration steps may vary by version and deployment model. Use this document for the OS-side prerequisites.

---

## 1) Generate an SSH key for the monitoring user

On the monitoring server (or wherever the collector runs), generate a keypair.

Example (recommended):

```shell
ssh-keygen -t ed25519 -C "postgres"
```

Alternative (if required by policy/tools):

```shell
ssh-keygen -t rsa -b 4096 -C "postgres"
```

---

## 2) Install the public key on the PostgreSQL host

On the PostgreSQL host, add the public key to the target user’s `~/.ssh/authorized_keys`.

Example:

```shell
ssh-copy-id -i ~/.ssh/id_ed25519.pub <os_user>@<postgres_host>
```

---

## 3) Validate passwordless SSH

```shell
ssh <os_user>@<postgres_host> "whoami; hostname"
```

If this works without prompting for a password, most SSH-based collectors will be able to connect.

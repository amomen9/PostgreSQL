# Enable the `psql` Tool in pgAdmin Web (`ENABLE_PSQL`)

pgAdmin web can optionally allow launching `psql` from the UI. This is controlled by the `ENABLE_PSQL` setting.

---

## 1) Locate pgAdmin config file

Typical path:
- `/usr/pgadmin4/web/config.py`

If you’re not sure where it is:

```shell
sudo find / -name "config*.py" -type f 2>/dev/null | grep pgadmin

# Or search for the setting directly
sudo grep -rnw / -e 'ENABLE_PSQL' 2>/dev/null
```

---

## 2) Enable the setting

Edit the config file:

```shell
sudo vi /usr/pgadmin4/web/config.py
```

Set:

```python
ENABLE_PSQL = True
```

---

## 3) Apply changes

Re-run the pgAdmin web setup so the change is applied:

```shell
sudo /usr/pgadmin4/bin/setup-web.sh
```

# PGPOOL (Ubuntu)

### References

Follow [this link](./pgpool%20references.md).


---



### Installation:

After adding the PostgreSQL's official repository, you can find pgpool and its related packages.

**Install required packages:**

```shell
sudo apt-get update
sudo apt-get install pgpool2 libpgpool2 postgresql-15-pgpool2
```

postgresql-15-pgpool2 contains extensions for pgpool and is mandatory too. Choose the version of this package which corresponds with your pg major version.

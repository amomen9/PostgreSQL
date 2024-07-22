# PGPOOL (Ubuntu)

### References

pgpool explaination and sample setup:

[https://www.pgpool.net/docs/latest/en/html/example-cluster.html](https://www.pgpool.net/docs/latest/en/html/example-cluster.html)

For more, follow [this link](./pgpool%20references.md).

---

**Note:**

1. PostgreSQL major version specified here is 15. However, this manual also complies with most of the pg versions in use, including 13, 14, 15, and 16.
2. pgpool version is 4.5.2
3. Like many of the watchdog solutions for DBMS HA solutions, the watchdog can be installed on a highly available server, even a separate one. Here we setup the watchdog on all the nodes.
4. The following are the node details used in this documentation:

**Schematic of the sample pgpool replication topology setup (source: [pgpool.net](https://www.pgpool.net/docs/latest/en/html/example-cluster.html)):**

<div style="text-align:center;">
<img align="center" src="image/README/1721627485581.png" alt="1721627485581" style="width:600px;"/>
<br/>
</div>

<br/>
The replication topology is composed of:
<br/>

| row | Node hostname | IP Add        | Description            |
| --- | :------------: | ------------- | ---------------------- |
| 1   | funleashpgdb01 | 172.23.124.71 | Node 1 (synchronous)   |
| 2   | funleashpgdb02 | 172.23.124.72 | Node 2 (synchronous)  |
| 3   | funleashpgdb03 | 172.23.124.73 | Node 3 (asynchronous) |
| 4   |      vip      | 172.23.124.74 | floating virtual IP    |

### Installation:

Add the pg official repository and install PostgreSQL on all the nodes. After adding the PostgreSQL's official repository, you can find pgpool and its related packages in that repository.

1. **Install required packages:**

```shell
sudo apt-get update
sudo apt-get install pgpool2 libpgpool2 postgresql-15-pgpool2
```

postgresql-15-pgpool2 contains extensions for pgpool and is mandatory too. They will be mentioned later. Choose the version of this package which corresponds with your pg major version.

1. **Copy template files:**

copy template script files from the following directory to a specific directory, rename and remove .sample from the end of the files.
cp /usr/share/doc/pgpool2/examples/scripts/* /data/postgresql/scripts/

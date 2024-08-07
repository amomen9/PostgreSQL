&nbsp;Doc parts:

* [Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)
* [Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)
* [Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)
* [Part IV: fix some glitches for Ubuntu](./Part%20IV%20fix%20some%20glitches%20for%20Ubuntu.md)
* [Part V: pgpool command, pcp, pgpool admin commands.md ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)
* [Part VI: Finish up, simulations, tests, notes.md ](./Part%20VI%20Finish%20up%2C%20simulations%2C%20tests%2C%20notes.md)


# PGPOOL (Ubuntu) Part VI

### Finish up, simulations, tests, notes

As noted, every installation, configuration, and fixation is almost ready. First, we do the following which we also noted in Part I.
 We say it again here.
 
#### 45. Stop postgres' service and remove postgres' data directory contents (Node 2nd and 3rd only, meaning the secondary nodes):

**Important Note!**
Only remove the contents of the data directory on the 2nd and 3rd nodes.

After installing and configuring postgres, remove postgres' data directory contents on the second and third nodes (be careful not to delete the data directory itself), because at some point forward we are going to recover the second and third nodes from the first node using pgpool's online recovery process completely and at such point the data directory must be clean:

```shell
pg_ctlcluster 15 main stop -m immediate	# for pg version '15', and cluster name 'main' which is the default cluster.

rm -rf $PGDATA/*
```

or

```shell
sudo systemctl stop postgresql@15-main.service	# for pg version '15', and cluster name 'main' which is the default cluster.

rm -rf $PGDATA/*
```

The first one can be executed by using the postgres user without the sudo privilege.

#### 46. Online recovery (Primary node only)

We execute the PCP online recovery command like below on the primary node. It will in turn, build up the data directory
 on the secondary nodes.

This process includes running the following two scripts in order:
`$PGDATA/recovery_1st_stage`
`$PGDATA/pgpool_remote_start`

Meaning, the data directory will be built up and the database cluster will also be started.

Now, everything has completely been carried out and our cluster is ready. We can now put it
 to test for manual and automatic failovers and also connecting the application to the pgPool
 proxy port that in our case, it is on port 9999
 
Note that in the event of a manual failover, you have to rebuild the old primary after it is
 brought up.
<br/><br/>


Finish ■

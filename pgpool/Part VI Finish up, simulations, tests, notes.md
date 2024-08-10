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
 
#### 48. Stop postgres' service and remove postgres' data directory contents (Node 2nd and 3rd only, meaning the secondary nodes):

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

#### 49. Online recovery (Primary node only)

We execute the PCP online recovery command like below on the primary node. It will in turn, build up the data directory
 on the secondary nodes.

This process includes running the following two scripts in order:
`$PGDATA/recovery_1st_stage`
`$PGDATA/pgpool_remote_start`

Meaning, the data directory will be built up and the database cluster will also be started.

Now, everything has completely been carried out and our cluster is ready. We can now put it
 to test for manual and automatic failovers and also connecting the application to the pgPool
 proxy port which is the port 9999 in our case.
 
 
### Failover and Node Recovery:

#### 50. Disaster and Automatic Failover

In the event of a primary node disaster which brings it down, an automatic failover to a secondary node will occur
 and that secondary node will become the new primary. When a failover is triggered, the failover.sh script will be
 executed in the background. The failover process includes creating physical replication
 slots for the other standby nodes on the new primary node and connecting the new primary node as the read/write
 transaction leader to the other standby nodes. 

After the old primary is brought back online, it will be behind (maybe both ahead and behind, for which a combination
 of "undo of redo" and replay would be required) in the synchronization mechanism. Thus, we need to rebuild it and
 make it a new secondary. In such an event, the pcp_node_info reporting command would show **2 primaries**. One is
 the old one (which is actually a fake primary and is shown as primary because it is read/write and is not in a 
 recovery state) and the other is the new one. To bring the cluster back to a normal state, first we bring down the old
 primary using this command:

```shell
pg_ctlcluster 15 main stop -m immediate 
```

Subsequently, we recover it once again by issuing the following command:

```shell
pcp_recovery_node -h localhost -U pgpool -w -n 0
```

Note that here the 1st node is recovered from the current primary node. The recovery process is always
 carried out from the primary node. During the recovery process, the physical replication slot will also
 be created for the node which is being recovered as part of the recovery process.

#### 51. Manual Failover

In the event of a manual failover or a conditional failover in which the old primary node is somehow still
 in reach, in addition to the execution of failover.sh script, the follow_primary.sh will also be executed
 in the background for the old primary to synchronize itself with the new primary. This includes:

1. Trying to rewind the changes that the old primary might have been ahead of the new primary at the moment
 of the failover (using pg_rewind as a reverting process). If pg_rewind fails, the next step will be executed
 
2. The old primary will be fully recovered from scratch using pg_basebackup and set as a new secondary (and with 
 "in recovery" state).

3. The required physical replication slot will be added on the new primary for the new secondary.


<br/><br/>


Finish ■

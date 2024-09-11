# Manual Backup & Restore

<br/>

## Logical Backup/Restore (dump)

Using this approach, we can also backup/restore a specific database or table (logical backup and restore or dump)

* Backup/Restore the entire database cluster:

```shell
pg_dumpall -U postgres -h localhost -p 5432 > all_databases.sql			#On the source server

psql -U postgres -h localhost -p 5432 -f all_databases.sql 			#On the target server

```

* Backup/Restore a specific object

1. First, the latest backup is taken, and the restore process is performed according to step 3. (The three steps of the third stage should be done in the given order.) For that matter, first we take a dump of the database requested by the customer. For example, business_name:

```shell
pg_dump –U postgres –d business_name > business_name.sql			#(-t for a specific table)
```

2. Then we log in to the desired server machine and perform the following steps:

a. Drop the database if exists. **Be absolutely cautious to check you are not dropping something important or by mistake.**

```pgsql
drop database business_name; 	# if exists;
```

b. Create a raw database. **Set the owner to be the owner of the business service by practice.** The username is conventionally 
 the same as the database name.

```pgsql
create user business_name password 'StrongPaS$vV0rc1';				# if not exists
create database business_name owner business_name TABLESPACE tbs_test;
```


3. The final step is to restore the dump:

```shell
psql –U postgres business_name < business_name.sql					# -d flag can be omitted, and not including it still implies the target database
```

4. To check whether the database dump has been correctly restored, the following commands are executed:

```shell
su – postgres
psql\l+   # show databases with tablespaces
\c business_name testuser # connect to db
\dt # show tables or relations
\dn # show schema
```
<br/>
<hr style="border:3px;"/>
<br/>

**Backup & Restore in one line command:**

```shell
time \
PGPASSWORD=<Source Pass> pg_dump -h 172.23.171.41 -p 31977 -U postgres business_name | \
PGPASSWORD=<Target Pass> psql -h 172.23.36.11 -p 5432 -U postgres business_name
```
* Note: The terminal on which we execute the above command must have access to the both source and target servers on the required ports


<br/>
<br/>


Finish ■
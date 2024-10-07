# Manual Backup & Restore

<br/>

## Logical Backup/Restore (dump)

### pg_dump, pg_dumpall

**Important Note!!!**

pg_dump and pg_restore are for a single database management. Thus, they are not supported for

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
psql –U postgres business_name < business_name.sql				# -d flag can be omitted, and not including it still implies the target database
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

**Backup & Restore in one command:**

Sample:
```shell
time \
PGPASSWORD=<Source Pass> pg_dump -h 172.23.171.41 -p 31977 -U postgres business_name | \
PGPASSWORD=<Target Pass> psql -h 172.23.36.11 -p 5432 -U postgres business_name
# delete the last bash history line to avoid plain password record in it:
history -d $(history 1 | awk '{print $1}')
history -w

```
* Note: The terminal on which we execute the above command must have access to the both source and target servers on the required ports


<br/>
<br/>


**Take logical backup in archived format** (used with the **pg_restore** command)

The default format is _plain_ which is an ordinary SQL script. However, 3 other types like below can be
 specified which are archived. The output type is specified using the `-F` flag and one of the following
 type specifications. The result output of these formats can only be used with the **pg_restore** command:

* c:

Output a custom-format archive suitable for input into **pg_restore**. This is the most flexible option in
 that it allows manual selection and reordering of archived items during restore.
 It is also compressed by default.

* d:

Output a directory-format archive suitable for input into **pg_restore**. This will create a directory with one file for each
table and blob being dumped, plus a so-called Table of Contents file describing the dumped objects in a machine-readable
format. This format is compressed by default.

* tar:

Output a tar-format archive suitable for input into **pg_restore**. The tar format does not support
compression. _when_ _using_ _tar_ _format_ _the_ _relative_ _order_ _of_ _table_ _data_ _items_ _cannot_ _be_
 _changed_ _during_ _restore_


* Some `pg_dump` **useful** arguments:

```
-a
--data-only

-c
--clean
Use drop statements

-C
--create
Create target database first. This can be used together with --clean option to drop and recreate the target database.

-e pattern
--extension=pattern
Choose extensions to dump.

-f file
--file=file
Same as '>' after the command, but needed when 'directory' archive format is specified to name the directory.

-F format
--format=format

-n pattern
--schema=pattern

-N pattern
--exclude-schema=pattern

-O
--no-owner

-s
--schema-only

-t pattern
--table=pattern

-T pattern
--exclude-table=pattern

-Z 0..9
--compress=0..9

--exclude-table-data=pattern

--include-foreign-data=foreignserver

--inserts
Dump data as INSERT commands (rather than COPY).

--no-tablespaces
Do not output commands to select tablespaces. With this option, all objects will be created in whichever tablespace is the
default during restore.

-j njobs
--jobs=njobs
Run the dump in parallel by dumping njobs tables simultaneously.

```

---

### pg_restore

Summarized from the `pg_restore` man page:
> `pg_restore` is a utility for restoring a PostgreSQL database from an archive created by `pg_dump` in one of the **non-plain-text formats**. The archive
> files also allow pg_restore to be selective about what is restored, or even to reorder the
> items prior to being restored (not with all archive format options). The archive files are designed to be portable across architectures (like SQL commands).
>
> pg_restore can operate in two modes. If a database name is specified, pg_restore connects to that database and restores archive contents directly into the database. Otherwise, a
> script containing the SQL commands necessary to rebuild the database is created and written to a file or standard output. This script output is equivalent to the plain text output
> format of pg_dump. Some of the options controlling the output are therefore analogous to pg_dump options.


* Some `pg_restore` **useful** arguments:
As mentioned, some of the arguments are similar to pg_dump, and will not be noted here:
```
-l
--list
List the table of contents of the archive.
	
-L list-file
--use-list=list-file
Restore only those archive elements that are listed in list-file, and restore them in the order they appear in the file.

-P function-name(argtype [, ...])
--function=function-name(argtype [, ...])
Restore the named function only.

-1
--single-transaction
Execute the restore as a single transaction

-j number-of-jobs
--jobs=number-of-jobs
Run the most time-consuming steps of pg_restore — those that load data, create indexes, or create constraints — concurrently,
using up to number-of-jobs concurrent sessions. This option can dramatically reduce the time to restore a large database to a
server running on a multiprocessor machine. This option is ignored when emitting a script rather than connecting directly to
a database server.

-v
--verbose

```



**Backup & Restore in one command using pg_restore and compression:**

Sample:
```shell
time sh -c '
PGPASSWORD=<Source Pass> pg_dump -h 172.23.171.41 -p 31977 -U postgres unleash -Fd -f pg_db_dumpdir -j 8 && \
PGPASSWORD=<Target Pass> psql -h 172.23.64.71 -Upostgres -c "drop database if exists unleash WITH (FORCE)" && \
PGPASSWORD=<Target Pass> pg_restore -h 172.23.64.71 -Upostgres -d postgres -j 8 --create -v pg_db_dumpdir && \
rm -rf pg_db_dumpdir'

# delete the last bash history line to avoid plain password record in it:
history -d $(history 1 | awk '{print $1}')
history -w

```



<br/>
<br/>



Finish ■
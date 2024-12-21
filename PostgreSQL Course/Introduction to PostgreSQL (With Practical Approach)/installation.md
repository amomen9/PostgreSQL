# Installation:

## Notes:

* Here we do not discuss moving pg’s main installation directory.

* a postgresql instance is called postgresql database cluster or postgresql cluster in short.

* The instructions are mostly for RHEL and Debian linux distros. For other distros, it shall not be any more difficult anyway. Please note that if you have only worked with pg on RHEL, you should do some study on pg administration tasks on Ubuntu before being able to start the work on it.

* Ubuntu appeared relatively much easier to me (easier also depends on your use case, for you may not need the things that ubuntu does automatically), mostly in the sense that it automatically separates data and configuration directories and also different clusters and versions of pg and their service files through service templates (Read more about service templates if you need), and offering some extra functionalities to make some pg operations easier. You will find out more about these subsequently. It also initializes (creates cluster’s initial data) the default cluster and starts its service up as well by merely installing the package.

* Its packages are also sometimes more bundled. For example, for RHEL the packages for pg server and pg client are separated. But for Ubuntu they are not. However, on ubuntu the service files are handled differently. i.e. one main `postgresql.service` service and a service template with one service created for every pg database cluster. The name of the default-initiated cluster is “main” and its instantiated service from `postgresql@.service` is `postgresql@*-main.service`. The service naming in general is `postgresql@*-clustername.service`. The default-initiated cluster is called "main".

* As noted in the [Patroni documentation](../patroni/Part%20I%20Setup%20PostgreSQL%2C%20Patroni%2C%20and%20Watchdog.md), For the database clusters with large amount of data, I used to move the data directory to somewhere else.
 For example, /data/postgresql/13/main or whatever. However, later on I came to the conclusion that the best
 way is, at least regarding PostgreSQL, to keep everything in its default location and instead define mount
 points in the default locations and attach separate disks to those mount points. For example, prior to the
 installation of PostgreSQL, we can consider the following mount points:

- `/var/lib/postgresql/`
- `/var/log/`
- `/var/lib/etcd`
- `/var/lib/postgresql/17/main/pg_tblspc/`

Here is a sample figure of the disk layout:

![1.png](image/introduction2postgresql/1.png)

However, here we discuss moving the data directory for learning purposes. This might also be used somewhere by some of you if complies your taste and needs.

---

<br/>
<br/>
<br/>

## PostgreSQL Installation Methods


* There are several ways to install PostgreSQL. The most recommended one is installing from package repositories, as they are widely used
 and can resolve the requirements and prevent mismatches much more safely. Plus, you can upgrade the packages installed at no turmoil,
 and other requirements like service files, service users, symbolic links, default directories and standard locations are created automatically.
 
* Installation methods:
1. Compile from source, install dependencies first and compile from the source
2. Manually upload the binaries and other files to the server
3. Manually download bundled packages, meaning rpm, deb, or other bundled packages and install them with the native package installers
4. Use package managers (recommended)

As said before, the approaches 1 and 2 need extra work like moving the files, creating users and directories, configuration files, and service files.
 A small error in this operation could lead to big and unexpected troubles, but it may be a good exercise for learning purposes. It is advised that
 you do it once if you want to become a good expert at PostgreSQL, both at compiling any application from the source in general, and setting
 PostgreSQL compile-time configuration variables, like defining the size of index and heap files (Which is **1GB** by default).
 
* We explain installing from the package managers here.

---


<br/>
<br/>
<br/>
<br/>


## Start with PostgreSQL native installation on Linux:

The installation instructions are for RHEL And Ubuntu. RHEL explanations come first, the Ubuntu.
 The primary steps to install PostgreSQL on Alpine Linux are also noted very briefly. However, if you
 learn them and complete reading this document, you should have no problem installing pg on other distributions.

Obtain PostgreSQL repository from the official website, Enterprise DB, OS’s default repositories (OS repositories are nearly always outdated) etc.
 The best place to obtain the repositories is `postgresql.org` itself:

[PostgreSQL Downloads](https://www.postgresql.org/download/) 

Use the package managers to install PostgreSQL and PostgreSQL Contrib and cli (if not bundled with the main package) packages for the start.
 Later versions of PostgreSQL > 9.6 include contrib package in the main server package bundle:

### RHEL

```shell
# RHEL
sudo yum install postgresql17 postgresql17-contrib postgresql17-server
```

The database cluster will not be initialized and the service will not be started automatically. You manually have to do so.

### Ubuntu

```shell
# Debian
sudo apt install postgresql-17 postgresql-contrib 
```

The database cluster will be initialized and the service started automatically.


### Alpine Linux

First, add the required repositories to `/etc/apk/repositories`. Be careful to replace the Alpine major version with your Alpine version.


```shell
printf "
https://dl-cdn.alpinelinux.org/alpine/v<Alpine Version>/main
https://dl-cdn.alpinelinux.org/alpine/v<Alpine Version>/community
https://dl-cdn.alpinelinux.org/alpine/edge/testing
https://dl-cdn.alpinelinux.org/alpine/edge/main
https://dl-cdn.alpinelinux.org/alpine/edge/community
http://mirror.yandex.ru/mirrors/alpine/v<Alpine Version>/main/x86_64/APKINDEX.tar.gz /etc/apk/repositories
" >> /etc/apk/repositories
```

Then:

```shell
# Alpine Linux:
#(edge/main repository contains the latest PostgreSQL installation
sudo apk update
sudo apk add postgresql17 postgresql17-contrib
sudo pg_ctl initdb -D /var/lib/postgresql/data
sudo rc-update add postgresql boot
sudo rc-service postgresql start
sudo -u postgres psql
sudo rc-status postgresql
```

---

### Initialize the database cluster (RHEL)


As noted before, the data directory must be empty. Now we run the following binary

```shell
/usr/pgsql-*/bin/postgresql-*-setup initdb
```
or
```shell
/usr/bin/postgresql-*-setup initdb
```

This will initialize the database cluster in the PGDATA directory. If you wish to initialize the database cluster
 somewhere custom, read `postgresql-*-setup` manual, or simply execute the initdb binary alone like below:
 
```shell
/usr/pgsql-*/bin/initdb -D <Custome Data Directory Location>
```


![initmsg.png](image/introduction2postgresql/initmsg.png)
![initmsg2.png](image/introduction2postgresql/initmsg2.png)


The output can be as simple as the first above figure or the next one. Note that you have to see “OK” to make sure
 that everything has actually gone ok. If not,
 investigate initdb.log for problems as noted if you do not see enough info in the initidb command output.
 
 
Start and enable service:
```shell
sudo systemctl enable --now postgresql-*.service
```


Also take a look at the following

![pginitservice.png](image/introduction2postgresql/pginitservice.png)

---




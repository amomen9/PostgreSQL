&nbsp;Doc parts:

* [Part I: Install and Configure PostgreSQL for pgPool](./Part%20I%20Install%20and%20Configure%20PostgreSQL%20for%20pgPool.md)
* [Part II: Install and Configure pgPool](./Part%20II%20Install%20and%20Configure%20pgPool.md)
* [Part III: pgPool scripts](./Part%20III%20pgPool%20scripts.md)
* [Part IV: fix some glitches for Ubuntu](./Part%20IV%20fix%20some%20glitches%20for%20Ubuntu.md)
* [Part V: pgpool command, pcp, pgpool admin commands.md ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)
* [Part VI: Finish up, simulations, tests, notes.md ](./Part%20VI%20Finish%20up%2C%20simulations%2C%20tests%2C%20notes.md)


# PGPOOL (Ubuntu) Part IV

## Fix some glitches of pgpool for Ubuntu
 
#### Change heartbeat port (Every Node)

As I stated before, we changed the heartbeat port to **9999** (or proxy default port) instead of 9694 because this port will
 sometimes not come up. This is done in the pgpool.conf file.



* We place the following script files under /data/postgresql/scripts. So place these script files in a proper location which is the location that the service file uses for these scripts.

#### Copy the following script files to the target directory (Every Node)

Copy the following script files to the target directory and make them executable.
 The script file names are:
 
`remove_socket_symlinks.sh`

`correct pg data dir mode.sh`

`cluster_vip.sh`

`remove_socket_symlinks.sh`

Our place for these scripts is /data/postgresql/scripts

```shell
sudo chown -R postgres:postgres /data/postgresql
sudo chmod +x /data/postgresql/scripts/*
```


#### Remove socket files' residuals for the symbolic links (Every Node)

3. One other script is `remove_socket_symlinks.sh` to remove the residuals of the socket symbolic link files
 created by unix_domain_sockets_repair script at the startup of the pgpool service. This script is executed
 using a manually added ExecStartPre directive to the override of the pgpool service file.

This script is as follows: 

```shell
#!/bin/bash

/usr/bin/test -L /var/run/postgresql/.s.PGSQL.9999 && rm -f /var/run/postgresql/.s.PGSQL.9999 ; /usr/bin/test -L /tmp/.s.PGSQL.9999 && rm -f /tmp/.s.PGSQL.9999

/usr/bin/test -L /var/run/postgresql/.s.PGPOOLWD_CMD.9000 && rm -f /var/run/postgresql/.s.PGPOOLWD_CMD.9000 ; /usr/bin/test -L /tmp/.s.PGPOOLWD_CMD.9000 && rm -f /tmp/.s.PGPOOLWD_CMD.9000

/usr/bin/test -L /var/run/postgresql/.s.PGSQL.9898 && rm -f /var/run/postgresql/.s.PGSQL.9898 ; /usr/bin/test -L /tmp/.s.PGSQL.9898 && rm -f /tmp/.s.PGSQL.9898

true

```

To add this script, we do the following:

```shell
sudo systemctl edit pgpool2
```
Add the following in the place shown in the next image

```shell
[Service]

ExecStartPre=/bin/sh -c /data/postgresql/scripts/remove_socket_symlinks.sh
# This line is optional. -D discard pgpool2 nodes previuos status. -n skips running pgpool in systemd mode. For more info, refer to
# the official documentation.
ExecStart=
ExecStart=/usr/sbin/pgpool -D -n	
# -D discards pgpool_status file and is for development and test purposes. It is not recommended for the production environments.

```

![Screenshot_40](image/Part%20IV/Screenshot_40.png)

```shell
sudo systemctl daemon-reload
sudo systemctl restart pgpool2
```


#### Periodically check for unix domain socket files' symbolic links (Every Node)

#### Periodically check for the VIP (Every Node)

#### Periodically fix the mode for PGDATA directory (Every Node)

For these two above, we create a service to be periodically triggered by a timer.
 The service executes two scripts. 
 
1. Sometimes, the unix domain socket file is misplaced in another location.
 This causes for example the `psql -p 9999` command (or any other client) for connecting to the pgpool proxy to fail. 
 Thats's why we create a symbolic link for the socket file in a place that this command thinks it should
 look for. The name of the script for this is `unix_domain_sockets_repair.sh`.

This script is as follows:

```shell
#!/bin/bash


# create symbolic link to the socket file if not exists
# 9999
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9999); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9999); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /tmp/$FILE_NAME 				 && /usr/bin/test ! -S /var/run/postgresql/$FILE_NAME && /usr/bin/ln -s /tmp/$FILE_NAME 				 /var/run/postgresql/$FILE_NAME  || /usr/bin/test -S /var/run/postgresql/$FILE_NAME'
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9999); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9999); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /var/run/postgresql/$FILE_NAME && /usr/bin/test ! -S /tmp/$FILE_NAME 				 && /usr/bin/ln -s /var/run/postgresql/$FILE_NAME /tmp/$FILE_NAME 				|| /usr/bin/test -S /tmp/$FILE_NAME'
# 9898
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9898); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9898); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /tmp/$FILE_NAME 				 && /usr/bin/test ! -S /var/run/postgresql/$FILE_NAME && /usr/bin/ln -s /tmp/$FILE_NAME 				 /var/run/postgresql/$FILE_NAME  || /usr/bin/test -S /var/run/postgresql/$FILE_NAME'
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9898); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9898); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /var/run/postgresql/$FILE_NAME && /usr/bin/test ! -S /tmp/$FILE_NAME 				 && /usr/bin/ln -s /var/run/postgresql/$FILE_NAME /tmp/$FILE_NAME 				|| /usr/bin/test -S /tmp/$FILE_NAME'
# 9000
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9000); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9000); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /tmp/$FILE_NAME 				 && /usr/bin/test ! -S /run/postgresql/$FILE_NAME 	 && /usr/bin/ln -s /tmp/$FILE_NAME 				 /run/postgresql/$FILE_NAME  		|| /usr/bin/test -S /run/postgresql/$FILE_NAME'
/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9000); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9000); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /run/postgresql/$FILE_NAME 	 && /usr/bin/test ! -S /tmp/$FILE_NAME 				 && /usr/bin/ln -s /run/postgresql/$FILE_NAME /tmp/$FILE_NAME 					|| /usr/bin/test -S /tmp/$FILE_NAME'
# 9694: this port is handled in pgpool.conf and must not be handled here anymore,
# unless the modification of hearbeat_port directive in pgpool.conf be reverted to 9694 
#ExecStart=/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9694); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9694); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /tmp/$FILE_NAME 				  && /usr/bin/test ! -S /var/run/postgresql/$FILE_NAME && /usr/bin/ln -s /tmp/$FILE_NAME 				 /var/run/postgresql/$FILE_NAME  || /usr/bin/test -S /var/run/postgresql/$FILE_NAME'
#ExecStart=/bin/sh -c 'FILE_NAME=$(ls -1a /var/run/postgresql/ | grep '\.s\.' | grep 9694); [ "$FILE_NAME" = "" ] && FILE_NAME=$(ls -1a /tmp/ | grep '\.s\.' | grep 9694); [ "$FILE_NAME" != "" ] && /usr/bin/test -S /var/run/postgresql/$FILE_NAME && /usr/bin/test ! -S /tmp/$FILE_NAME 				  && /usr/bin/ln -s /var/run/postgresql/$FILE_NAME /tmp/$FILE_NAME 				|| /usr/bin/test -S /tmp/$FILE_NAME'

/usr/bin/chown -R postgres:postgres {/var/run/postgresql,}

```


2. Another script `cluster_vip.sh` is to bring the virtual IP up on the primary node if not exists.


* Set the value of the parameter **DEVICE** in this script manually if you have multiple
 interfaces except the loopback interface. Otherwise, the formula will work. 
 
This script is as follows:

```shell
#!/bin/bash
DEVICE=$(ip -br link | awk '$1 != "lo" {print $1}' | tail -1)
PRIMARY_NODE=$(echo $(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | head -$(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1) | tail -1 | cut -d" " -f1))

# Command to be executed
cmd="ssh -T -i ~/.ssh/id_rsa_pgpool ${PRIMARY_NODE} /usr/bin/sudo /sbin/ip addr add 172.23.124.74/24 dev ${DEVICE} label ${DEVICE}:0"

# Execute the command and capture the output
output=$($cmd 2>&1)

exit_code=$?
echo $exit_code

if [ "$PRIMARY_NODE" == "$(hostname)" ]; then
	cmd="ssh -T -i ~/.ssh/id_rsa_pgpool $(echo $(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | head -$(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1) | tail -1 | cut -d" " -f1)) /etc/pgpool2/scripts/escalation.sh"
	eval $cmd
fi

# Check if the output matches the desired string
if [ "$output" == "RTNETLINK answers: File exists" ]; then
# If yes, return exit code 0
	exit 0
else
# If not, return the original exit code
	exit $exit_code
fi


```


3. Sometimes the mode for PGDATA directory might change probably by pgpool. We now that this mode must be either
 0700 or 0755 when PostgreSQL wants to start. The script which ascertains consistence of this necessity is called
 `correct pg data dir mode.sh`

This script is as follows: 

```shell
#!/bin/bash

/usr/bin/chmod -R 0750 /data/postgresql
```

####  Create the service file and the timer (Every Node)

Now create a service file and timer for these scripts. The name of the service file is `pgpool_repair.service`:

```shell
sudo vi /lib/systemd/system/pgpool_repair.service
```

Write the following inside:

```shell
[Unit]
Description=pgpool socket repair service
After=network.target
After=multi-user.target
After=sshd.service
After=pgpool2.service
Wants=pgpool_repair.timer

[Service]
Type=oneshot

User=postgres
Group=postgres


# Where to send early-startup messages from the server
# This is normally controlled by the global default set by systemd
StandardOutput=syslog

# Disable OOM kill on the scripts
OOMScoreAdjust=-1000
Environment=PGB_OOM_ADJUST_FILE=/proc/self/oom_score_adj
Environment=PGB_OOM_ADJUST_VALUE=0

# create symbolic link to the socket file if not exists
ExecStart=/bin/sh -c /data/postgresql/scripts/unix_domain_sockets_repair.sh

SuccessExitStatus=0 1 2

# assign vip to the primary node if not already assigned
ExecStart=/bin/sh -c /data/postgresql/scripts/cluster_vip.sh

StandardOutput=journal
StandardError=journal+console

[Install]
WantedBy=multi-user.target

```

Now the timer file for the service. The name of the timer file is `pgpool_repair.timer`:

```shell
sudo vi /lib/systemd/system/pgpool_repair.timer
```

Write the following inside:

```shell
# Timer for the service

[Unit]
Description=Executes socket repair operation
Requires=pgpool_repair.service

[Timer]
Unit=pgpool_repair.service
OnCalendar=*:*:0/10
AccuracySec=1s

[Install]
WantedBy=timers.target

```

This timer triggers the service every 10 seconds. For more info on timers, services, and their scheduling 
 you can refer to the following link on this git repository:
 
[Systemd Service and Timer](https://git.mofid.dev/a.momen/linux/-/blob/master/Systemd%20Service%20and%20Timer/README.md)

Now:

```shell
sudo systemctl daemon-reload
sudo systemctl enable pgpool_repair.timer
```

The service will run every 10 seconds`


Now every installation, configuration, and fixation appears to be ready. Continue to the next parts.


# [Next: Part V: pgpool, pcp, pgpool admin commands ](./Part%20V%20pgpool%20command%2C%20pcp%2C%20pgpool%20admin%20commands.md)


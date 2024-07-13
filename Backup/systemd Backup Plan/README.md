# systemd Backup Automation

The systemd backup automation plan is composed of a service template with two timers. One of the timers triggers the service instance for compressing, backing up, and purging the old WAL files. The other one triggers the same for full backups. The backups are created in gzip format. The instantiated services run some scripts. All of them will be briefly explained below.

1. [X] **Scripts**
1. [ ] 
    1.

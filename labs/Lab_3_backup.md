**[Back to Agenda](./../README.md)**

# Lab 3 - Backup a MySQL Cluster

Backup and restore of NDB Cluster can be done centralized by MySQL Cluster Manager. NDB also have native backup and restore for community edition of NDB, more details [here](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-backup.html).

As NDB Cluster is a ditributed database, the backup is also a distributed where each datanode will backup it's part of the complete dataset. Important that you make sure all parts of the backup are stored in a safe manner.

#### Backup and Recovery

Start the mcm client
If you want to see help run `./mcm/bin/mcm --help`
Our reference manual can be found [here](https://dev.mysql.com/doc/mysql-cluster-manager/1.4/en/mcm-cluster-commands.html).

```
./mcm/bin/mcm
```
Run a full backup of the cluster:
```
mcm> backup cluster mycluster;
```

List backups:
```
mcm> list backups mycluster;
```

**[Back to Agenda](./../README.md)**

**[Back to Agenda](./../README.md)**

# Lab 3 - Backup a MySQL Cluster

Backup and restore of NDB Cluster can be done centralized by MySQL Cluster Manager. NDB also have native backup and restore for community edition of NDB, more details [here](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-backup.html).

As NDB Cluster is a distributed database, the backup is also a distributed where each datanode will backup it's part of the complete dataset. Important that you make sure all parts of the backup are stored in a safe manner.

Local data/metadata in MySQL API nodes are not part of NDB backup, this data must be handled separately. This data can be secured by using [mysqldump](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html) separately.

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
If you have 2 mcm windows open you can track progress by running:
```
mcm> show status --progress mycluster;
```
Once the backup is done use `list backups` to list stored backups:
```
mcm> list backups mycluster;
```

Log into MySQL client:
```
mysql -uroot -proot -h127.0.0.1 -P3310
```
And create some data:
```
mysql> create database lab;
mysql> use lab;
mysql> create table t1 (i int) engine=ndbcluster;
mysql> insert into t1 values (1),(2),(3);
```

Lets create a backup (in mcm client) to make sure we can recover in case of disaster
```
mcm> backup cluster mycluster;
```
Disaster strikes!
```
mysql -uroot -proot -h127.0.0.1 -P3310 -se"drop database lab"
```
Lets recover from last backup, first look at available backups and pick the last one, note the *BackupId*
```
mcm> list backups mycluster;
```
Next step is to use recover the data using *BackupId* from above
```
mcm> restore cluster --backupid=3 --background mycluster;
```
During recovery is running look at:
```
mcm> show status --progressbar mycluster;
```
If you want to re-run recovery just run the Disaster statment over again ;)

**[Back to Agenda](./../README.md)**

**[Back to Agenda](./../README.md)**

# Lab 7 - Adding Geographic redundancy to MySQL Cluster

With MySQL Cluster you have two options to achieve geographic redundancy, either you create 2 MySQL Cluster sites in different locations and use MySQL asynchronous replication to keep them in sync or you 'streach' one installation of one cluster over 2 locations separated by some distance.

##### Two Cluster Sites and async replication
``` 
          DC1                                           DC2
        -------                                       -------
    MySQL      MySQL        -------------->       MySQL       MySQL
                              async repl
------------------------                       --------------------------
| DataNode1  DataNode2 |                       | DataNode1    DataNode2 |  Node Group 1
------------------------                       --------------------------
------------------------                       --------------------------
| DataNode3  DataNode4 |                       | DataNode3    DataNode4 |  Node Group 2
------------------------                       --------------------------
```
##### One streached cluster
```
         DC1                                           DC2
       -------                                       -------
   MySQL      MySQL                              MySQL      MySQL
-------------------------------------------------------------------------
|     DataNode1                                      DataNode2          |  Node Group 1
-------------------------------------------------------------------------
-------------------------------------------------------------------------
|     DataNode3                                      DataNode4          |  Node Group 2
-------------------------------------------------------------------------
 
```

Creating two Cluster with replication
---------------

#### Active/Passive setup

Target toplogy:
```
   MySQL Site-1               MySQL Site-2
 ==========================================
   MySQL-53316 -------------> MySQL-53326 (slave)
   MySQL-53317                MySQL-53327
   Data Node                  Data Node
   Data Node                  Data Node
```

if you have already created some cluster, remove everything:
```
./scripts/reset.sh
```
We will first create 2 cluster using MCM:
```
mcm < mcm-templates/replication-cluster
```
Look at commands in file `mcm-templates/replication-cluster`

Next step is to start replication from MySQL-53316 -> MySQL-53326
```
./scripts/start-replication.sh
```
Look at commands in script `scripts/start-replication.sh`

Import some data on MySQL node in Site-1
```
mysql -uroot -P53317 -h127.0.0.1 < tools/create-ndb-testdata.sql
```

Look at max EPOCH replicated on both slaves (53326 and 53327):
```
(mysql -uroot -P53326 -h127.0.0.1)
mysql> SELECT MAX(epoch) FROM mysql.ndb_apply_status\G"
mysql> SELECT @@PORT;
```
Run some data import on both MySQL node in Site-1
```
mysql -uroot -P53316 -h127.0.0.1 < tools/create-ndb-testdata.sql
mysql -uroot -P53317 -h127.0.0.1 < tools/create-ndb-testdata.sql
```
And look at: `watch ./scripts/slave-epocs.sh` at the same time.
Both MySQL nodes should have same status.

Run channel cut-over from MySQL-53316 -> MySQL-53326 to MySQL-53317 -> MySQL-53327
```
./scripts/chanel-cut-over.sh
```
Remember to only have one replication channel active at any point in time, otherwice there will be problem!

If you want to re-create the test simply run:
```
./scripts/reset.sh
```
And we can start from the beginning by creating the 2 clusters.

#### Active/Active setup anf conflict resolution
Will be added soon ...

**[Back to Agenda](./../README.md)**

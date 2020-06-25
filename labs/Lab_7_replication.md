**[Back to Agenda](./../README.md)**

# Lab 7 - Adding Geographic redundancy to MySQL Cluster

With MySQL Cluster you have two options to achieve geographic redundancy, either you create 2 MySQL Cluster sites in different locations and use MySQL asynchronous replication to keep them in sync or you 'stretch' one installation of one cluster over 2 locations separated by some distance.

More information in our manual [here](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-replication.html).

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

With this architecture there no problems with latency between DC's but you need to manually setup asynchronous replication as described bellow.
Best practices is to have dedicated MySQL API nodes for replication (2 on each site for redundancy and channel cut-over).
This is our standard architecture of achieving a failover site for disaster recovery.

##### One stretched cluster
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

This is basically one cluster stretched over 2 DC.

Very important to be aware of:
- this architecture will impact your responce times if the latency is high between the 2 DC.
- make sure you configure cluster so node groups are spanning both DC as seen in picture above.

This architecture is best used if you have reliable and low latency connectivity between the 2 DC.
Also important to note that some of the latency problem can be worked around if your application is multi-threaded.

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
./replication-scripts/start-replication.sh
```
Look at commands in script `replication-scripts/start-replication.sh`

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

Let's see how efficient we are batching on slaver server (log into slave server 53326)
```
mysql> SELECT * from performance_schema.global_status WHERE VARIABLE_NAME IN ('Ndb_api_wait_exec_complete_count_slave','Ndb_api_trans_commit_count_slave','Ndb_api_bytes_sent_count_slave');
```
Ndb_api_wait_exec_complete_count_slave - Roughly slave batch count  
Ndb_api_bytes_sent_count_slave - Roughly amount of data applied  
Ndb_api_trans_commit_count_slave - Roughly the number of binlog transactions applied

Insert some data on either MySQL-53316 or MySQL-53317
(mysql -uroot -P53316 -h127.0.0.1)
```
mysql> create database test;
mysql> use test;
mysql> create table t1 (i int) engine=ndbcluster;
mysql> insert into test.t1 values (2); insert into test.t1 values (3); insert into test.t1 values (4); insert into test.t1 values (7);
```
Run the insert statement multiple times and look at output from `performance_schema.global_status` above.

Disable batching
```
mcm> set slave_allow_batching:mysqld=0 mycluster2;
```
And run some more insert statemets (inserting 4 rows) and look at batching efficiency using SELECT statement above.
In this small test we see that batching works well when enabled, the value of Ndb_api_wait_exec_complete_count_slave and Ndb_api_trans_commit_count_slave have matching numbers.

Run channel cut-over from MySQL-53316 -> MySQL-53326 to MySQL-53317 -> MySQL-53327
```
./replication-scripts/chanel-cut-over.sh
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

**[Back to Agenda](./../README.md)**

# Lab 4 - Monitoring a MySQL Cluster

Monitoring NBD Cluster can be done by using [MySQL Enterprise Monitor](https://www.mysql.com/products/enterprise/monitor.html). MySQL Enterprise Monitor is a graphical monitoring system that can be used to get a high level view of your cluster status, it can also fire off alarms if something is not working correctly.

Low level diagnostics on what is happening in MySQL cluster is available via a set of tables in the `ndbinfo` schema. All tables in `ndbinfo` schema are described in detail in our [manual](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-ndbinfo.html). 

#### NDBINFO tables
Not all tables of the NDBINFO schema will be explained below, we will cover the most frequeltly used ones but all of them are important to understand in a production environment.

Start the MySQL client (if you want to see 'help' run `mysql --help`)

```
mysql -uroot -proot -P3311 -h127.0.0.1 ndbinfo
  or provide socket file like:
mysql -uroot -proot -S/tmp/mysql.mycluster.50.sock  ndbinfo
```

###### *node*  
Current status of our datanodes. Beside current status this table also contains, uptime since last re-start, start phase during restart and configuration version being used. This information is very good to have during rolling restarts.
```
mysql> select * from nodes;
+---------+--------+---------+-------------+-------------------+
| node_id | uptime | status  | start_phase | config_generation |
+---------+--------+---------+-------------+-------------------+
|       1 |   1205 | STARTED |           0 |                 0 |
|       2 |   1205 | STARTED |           0 |                 0 |
+---------+--------+---------+-------------+-------------------+
```
*threads*  
The threads table provides information about threads running in the NDB kernel.
```
mysql> select * from threads;
+---------+--------+-------------+------------------------------------------------------------------+
| node_id | thr_no | thread_name | thread_description                                               |
+---------+--------+-------------+------------------------------------------------------------------+
|       1 |      0 | main        | main thread, schema and distribution handling                    |
|       1 |      1 | rep         | rep thread, asynch replication and proxy block handling          |
|       1 |      2 | ldm         | ldm thread, handling a set of data partitions                    |
|       1 |      3 | recv        | receive thread, performing receieve and polling for new receives |
|       2 |      0 | main        | main thread, schema and distribution handling                    |
|       2 |      1 | rep         | rep thread, asynch replication and proxy block handling          |
|       2 |      2 | ldm         | ldm thread, handling a set of data partitions                    |
|       2 |      3 | recv        | receive thread, performing receieve and polling for new receives |
+---------+--------+-------------+------------------------------------------------------------------+
```
The threads table is usually joined with *cpuststat* and *threadstat* tables on node_id and thr_no to print column thread_name for clarity like:
```
mysql> select t.node_id, t.thread_name,c.OS_user,c.OS_system,c.OS_idle from cpustat c join threads t on t.node_id=c.node_id AND t.thr_no=c.thr_no;
+---------+-------------+---------+-----------+---------+
| node_id | thread_name | OS_user | OS_system | OS_idle |
+---------+-------------+---------+-----------+---------+
|       1 | main        |       0 |         1 |      99 |
|       1 | rep         |       0 |         1 |      99 |
|       1 | ldm         |       0 |         1 |      99 |
|       1 | recv        |       2 |         2 |      96 |
|       2 | main        |       0 |         1 |      99 |
|       2 | rep         |       0 |         1 |      99 |
|       2 | ldm         |       0 |         1 |      99 |
|       2 | recv        |       2 |         2 |      96 |
+---------+-------------+---------+-----------+---------+
8 rows in set (0,03 sec)

```

*memoryusage*  
This table contains index/data memory usage per data nodes (node_id 1 and 2 are our 2 data nodes).
```
mysql> SELECT * from ndbinfo.memoryusage;
+---------+---------------------+--------+------------+----------+-------------+
| node_id | memory_type         | used   | used_pages | total    | total_pages |
+---------+---------------------+--------+------------+----------+-------------+
|       1 | Data memory         | 753664 |         23 | 83886080 |        2560 |
|       1 | Index memory        | 163840 |         20 | 19136512 |        2336 |
|       1 | Long message buffer | 262144 |       1024 | 67108864 |      262144 |
|       2 | Data memory         | 753664 |         23 | 83886080 |        2560 |
|       2 | Index memory        | 163840 |         20 | 19136512 |        2336 |
|       2 | Long message buffer | 262144 |       1024 | 67108864 |      262144 |
+---------+---------------------+--------+------------+----------+-------------+
```

*memory_per_fragment*  
Memory usage by individual fragments. This table can be used for investigating memory usage for all "user defined" tables with query below. If you want to filer out some schemas or tables add *where* clause to statement and filter on `fq_name`, format of *fq_name* is <schema>/def/<table>.
```
mysql> SELECT fq_name as TableName, SUM(var_elem_alloc_bytes) as VarMem, SUM(fixed_elem_alloc_bytes) as FixedMem, SUM(hash_index_alloc_bytes) as IndexMEM  from memory_per_fragment WHERE type="User table" GROUP BY fq_name;
+---------------------------------+--------+----------+----------+
| TableName                       | VarMem | FixedMem | IndexMEM |
+---------------------------------+--------+----------+----------+
| mysql/def/NDB$BLOB_7_3          |      0 |        0 |    32768 |
| mysql/def/ndb_apply_status      |      0 |        0 |    32768 |
| mysql/def/ndb_index_stat_head   |      0 |        0 |    32768 |
| mysql/def/ndb_index_stat_sample |      0 |        0 |    32768 |
| mysql/def/ndb_schema            |      0 |        0 |    32768 |
+---------------------------------+--------+----------+----------+
```

*config_nodes*  
MySQL Cluster nodes currently configured in the config.ini. This table does not say anything about the state of the nodes.

```
mysql> select * from config_nodes;
+---------+-----------+---------------+
| node_id | node_type | node_hostname |
+---------+-----------+---------------+
|       1 | NDB       | 127.0.0.1     |
|       2 | NDB       | 127.0.0.1     |
|      49 | MGM       | 127.0.0.1     |
|      50 | API       | 127.0.0.1     |
|      51 | API       | 127.0.0.1     |
|      52 | API       | 127.0.0.1     |
|      53 | API       | 127.0.0.1     |
|      54 | API       | 127.0.0.1     |
|      55 | API       | 127.0.0.1     |
+---------+-----------+---------------+
```


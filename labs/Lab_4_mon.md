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

*node*  
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
Memory usage by individual fragments. This table can be used for seeing memory usage for all "user defined" tables with query below.
```
mysql> SELECT fq_name as TableName, sum(var_elem_alloc_bytes) as VarMem,  SUM(fixed_elem_alloc_bytes) as FixedMem, SUM(hash_index_alloc_bytes) as IndexMEM  from memory_per_fragment WHERE type="User table" GROUP BY fq_name;
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




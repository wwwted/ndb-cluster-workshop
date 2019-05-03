**[Back to Agenda](./../README.md)**

# Lab 4 - Monitoring a MySQL Cluster

Monitoring NBD Cluster can be done by using [MySQL Enterprise Monitor](https://www.mysql.com/products/enterprise/monitor.html). MySQL Enterprise Monitor is a graphical monitoring system that can be used to get a high level view of your cluster status, it can also fire off alarms if something is not working correctly.

Low level diagnostics on what is happening in MySQL cluster is available via a set of tables in the `ndbinfo` schema. All tables in `ndbinfo` schema are described in detail in our [manual](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-ndbinfo.html). 

NDBINFO tables
---------------
Not all tables in the NDBINFO schema will be explained below, we will cover the most frequeltly used ones but all of them are important to understand in a production environment.

Start the MySQL client (if you want to see 'help' run `mysql --help`)

```
mysql -uroot -proot -P3311 -h127.0.0.1 ndbinfo
  or provide socket file like:
mysql -uroot -proot -S/tmp/mysql.mycluster.50.sock  ndbinfo
```
Before we start running queries aganst ndbinfo tables lets add some random data, copy commands [here](https://gist.github.com/wwwted/10656c765dac2c988ba567d5c710c7e6) put them in a file named *create_ndb_testdata.sql* or download zip-file and then run command below.
```
mysql -uroot -proot -P3311 -h127.0.0.1 < create_ndb_testdata.sql
```

#### dict_obj_info
The dict_obj_info table provides information about NDB data dictionary (DICT) objects such as tables and indexes.
Lets find some information about our test table created above, if you want to filter out some schemas or tables add where clause to statement and filter on fq_name, format of fq_name is \<schema\>/def/\<table\> as seen for our test table below.
```
mysql> select * from dict_obj_info where fq_name='ted/def/test';                   
+------+------+---------+-------+-----------------+---------------+--------------+
| type | id   | version | state | parent_obj_type | parent_obj_id | fq_name      |
+------+------+---------+-------+-----------------+---------------+--------------+
|    2 |   10 |       1 |     4 |               0 |             0 | ted/def/test |
+------+------+---------+-------+-----------------+---------------+--------------+
```
There are different type of objects in the dict_obj_info table, the types can be seen in table *dict_obj_types* or by joining this table like below. Type `2` means `User Table`.
```
mysql> select dot.type_name,doi.* from dict_obj_info doi, dict_obj_types dot where doi.type=dot.type_id and fq_name='ted/def/test'; 
+------------+------+------+---------+-------+-----------------+---------------+--------------+
| type_name  | type | id   | version | state | parent_obj_type | parent_obj_id | fq_name      |
+------------+------+------+---------+-------+-----------------+---------------+--------------+
| User table |    2 |   10 |       1 |     4 |               0 |             0 | ted/def/test |
+------------+------+------+---------+-------+-----------------+---------------+--------------+
```
If we look at all rows in table dict_obj_info we can see that when we created our test table above 5 objects where created, lets look at what rows have our table id as *parent_obj_id*.
```
mysql> select dot.type_name, do2.id,do2.parent_obj_id, do2.fq_name from dict_obj_info do1, dict_obj_info do2, dict_obj_types dot where do1.id=do2.parent_obj_id and dot.type_id=do2.type and do1.id=10;
+---------------+------+---------------+--------------------+
| type_name     | id   | parent_obj_id | fq_name            |
+---------------+------+---------------+--------------------+
| Ordered index |   11 |            10 | sys/def/10/PRIMARY |
| Ordered index |   12 |            10 | sys/def/10/name    |
+---------------+------+---------------+--------------------+
```
As you can see there are 2 orderered indexes also created together with our table, if you dive even further you will see two index triggers that where created and are connected to our Ordered indexes above.
```
mysql> select dot.type_name, do2.id,do2.parent_obj_id, do2.fq_name from dict_obj_info do1, dict_obj_info do2, dict_obj_types dot where do1.id=do2.parent_obj_id and dot.type_id=do2.type and (do1.id=11 or do1.id=12);
+---------------+------+---------------+---------------------+
| type_name     | id   | parent_obj_id | fq_name             |
+---------------+------+---------------+---------------------+
| Index trigger |    1 |            11 | NDB$INDEX_11_CUSTOM |
| Index trigger |    2 |            12 | NDB$INDEX_12_CUSTOM |
+---------------+------+---------------+---------------------+
```

#### config_values and config_params
All the configuration of NBD data nodes is stored in table config_values, additional meta data is stored in table config_params. If you want to find all parameter settings for LCP do a search like:
```
mysql> SELECT cv.node_id, cp.param_name, cv.config_value FROM config_values cv, config_params cp WHERE cv.config_param=cp.param_number AND cp.param_name LIKE '%lcp%';
+---------+------------------------+--------------+
| node_id | param_name             | config_value |
+---------+------------------------+--------------+
|       1 | CompressedLCP          | 0            |
|       2 | CompressedLCP          | 0            |
|       1 | MaxLCPStartDelay       | 0            |
|       2 | MaxLCPStartDelay       | 0            |
|       1 | LcpScanProgressTimeout | 60           |
|       2 | LcpScanProgressTimeout | 60           |
|       1 | EnablePartialLcp       | 1            |
|       2 | EnablePartialLcp       | 1            |
+---------+------------------------+--------------+
```

#### node
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
#### threads
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

#### memoryusage
This table contains index/data memory usage per data nodes (node_id 1 and 2 are our 2 data nodes).
```
mysql> SELECT * from ndbinfo.memoryusage;
+---------+---------------------+---------+------------+----------+-------------+
| node_id | memory_type         | used    | used_pages | total    | total_pages |
+---------+---------------------+---------+------------+----------+-------------+
|       1 | Data memory         | 1933312 |         59 | 83886080 |        2560 |
|       1 | Index memory        |  335872 |         41 | 19136512 |        2336 |
|       1 | Long message buffer |  131072 |        512 | 67108864 |      262144 |
|       2 | Data memory         | 1933312 |         59 | 83886080 |        2560 |
|       2 | Index memory        |  335872 |         41 | 19136512 |        2336 |
|       2 | Long message buffer |  393216 |       1536 | 67108864 |      262144 |
+---------+---------------------+---------+------------+----------+-------------+
```

#### memory_per_fragment
Memory usage by individual fragments. This table can be used for investigating memory usage for all "user defined" tables with query below. If you want to filer out some schemas or tables add *where* clause to statement and filter on `fq_name`, format of *fq_name* is \<schema\>/def/\<table\> as seen for our test table below.
```
mysql> SELECT fq_name as TableName, SUM(var_elem_alloc_bytes) as VarMem, SUM(fixed_elem_alloc_bytes) as FixedMem, SUM(hash_index_alloc_bytes) as IndexMEM  from ndbinfo.memory_per_fragment WHERE type="User table" GROUP BY fq_name;
+---------------------------------+--------+----------+----------+
| TableName                       | VarMem | FixedMem | IndexMEM |
+---------------------------------+--------+----------+----------+
| mysql/def/NDB$BLOB_7_3          |      0 |        0 |    32768 |
| mysql/def/ndb_apply_status      |      0 |        0 |    32768 |
| mysql/def/ndb_index_stat_head   |      0 |        0 |    32768 |
| mysql/def/ndb_index_stat_sample |      0 |        0 |    32768 |
| mysql/def/ndb_schema            | 131072 |   131072 |    65536 |
| ted/def/test                    | 655360 |   786432 |   311296 |
+---------------------------------+--------+----------+----------+
```
This will show total memory used by all fragments (primary and backup) in cluster, if we want to calculate average row size for a row in our table we should devide memory result above with our replication factor (default 2) and total amount of rows. If we want to size hardware (RAM) for our data nodes we need to also include backup fragments.  

For example) if we have 8 data nodes (on dedicated HW), each data node will have it's own primary partition of data and one backup partition (we will get 4 node groups (by default)), the amount of data memory needed per data node will be result of query above divided by 4 (primary and backup fragement must be counted). 

#### config_nodes
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
#### processes
List of all the processes currently running in the cluster.

```
mysql> select * from processes;
+---------+-----------+------------------------+------------+------------------+--------------+------------------------+
| node_id | node_type | node_version           | process_id | angel_process_id | process_name | service_URI            |
+---------+-----------+------------------------+------------+------------------+--------------+------------------------+
|       1 | NDB       | mysql-5.7.25 ndb-7.6.9 |       9421 |             NULL | ndbmtd       | ndb://127.0.0.1        |
|       2 | NDB       | mysql-5.7.25 ndb-7.6.9 |       9422 |             NULL | ndbmtd       | ndb://127.0.0.1        |
|      49 | MGM       | mysql-5.7.25 ndb-7.6.9 |       9392 |             NULL | ndb_mgmd     | ndb://127.0.0.1:1186   |
|      50 | API       | mysql-5.7.25 ndb-7.6.9 |       9798 |             NULL | mysqld       | mysql://127.0.0.1:3310 |
|      51 | API       | mysql-5.7.25 ndb-7.6.9 |      10038 |             NULL | mysqld       | mysql://127.0.0.1:3311 |
+---------+-----------+------------------------+------------+------------------+--------------+------------------------+
```

#### logspaces
This table provides information about NDB Cluster Redo log usage and space left. This information is good to monitor so you do not run out of redo log space, if this happens the cluster will reject new transations until we have freed (happens when we complete next local checkpoint) up space in the redo logs.
```
mysql> select * from logspaces;
+---------+----------+--------+----------+-----------+---------+
| node_id | log_type | log_id | log_part | total     | used    |
+---------+----------+--------+----------+-----------+---------+
|       1 | REDO     |      0 |        0 | 268435456 | 1048576 |
|       1 | REDO     |      0 |        1 | 268435456 |       0 |
|       1 | REDO     |      0 |        2 | 268435456 |       0 |
|       1 | REDO     |      0 |        3 | 268435456 |       0 |
|       2 | REDO     |      0 |        0 | 268435456 | 1048576 |
|       2 | REDO     |      0 |        1 | 268435456 |       0 |
|       2 | REDO     |      0 |        2 | 268435456 |       0 |
|       2 | REDO     |      0 |        3 | 268435456 |       0 |
+---------+----------+--------+----------+-----------+---------+
```

There are many more tables that are interesting in then ndbinfo tables and we will look at some more when we have some load on the system.

External Tools
---------------

##### ndb_show_tables
Will list all tables in our cluster
```
ted@speedy:~/ws-mcm$ ndb_show_tables
id    type                 state    logging database     schema   name
1     IndexTrigger         Online   -                             NDB$INDEX_11_CUSTOM
8     UserTable            Online   Yes     mysql        def      NDB$BLOB_7_3
10    UserTable            Online   Yes     ted          def      test
5     UserTable            Online   Yes     mysql        def      ndb_index_stat_sample
...
```
We can then specify our test table ted.test and see what internal tables in schema *sys* was created
```
ted@speedy:~/ws-mcm$ ndb_show_tables -dted test
id    type                 state    logging database     schema   name
11    OrderedIndex         Online   No      sys          def      PRIMARY
12    OrderedIndex         Online   No      sys          def      name
```
As you can see we see have 2 internal tables for ordered indexes.

##### ndb_desc
Provides meta data information on the table and also partition statistics.

```
ted@speedy:~/ws-mcm$ ndb_desc -dted -p test
-- test --
Version: 1
Fragment type: HashMapPartition
K Value: 6
Min load factor: 78
Max load factor: 80
Temporary table: no
Number of attributes: 4
Number of primary keys: 1
Length of frm data: 328
Max Rows: 0
Row Checksum: 1
Row GCI: 1
SingleUserMode: 0
ForceVarPart: 1
PartitionCount: 2
FragmentCount: 2
PartitionBalance: FOR_RP_BY_LDM
ExtraRowGciBits: 0
ExtraRowAuthorBits: 0
TableStatus: Retrieved
Table options:
HashMap: DEFAULT-HASHMAP-3840-2
-- Attributes --
id Int PRIMARY KEY DISTRIBUTION KEY AT=FIXED ST=MEMORY AUTO_INCR
name Varchar(32;latin1_swedish_ci) NULL AT=SHORT_VAR ST=MEMORY
address Varchar(32;latin1_swedish_ci) NULL AT=SHORT_VAR ST=MEMORY
age Int NULL AT=FIXED ST=MEMORY
-- Indexes -- 
PRIMARY KEY(id) - UniqueHashIndex
PRIMARY(id) - OrderedIndex
name(name) - OrderedIndex
-- Per partition info -- 
Partition	Row count	Commit count	Frag fixed memory	Frag varsized memory	Extent_space	Free extent_space	
0         	5031     	5031        	196608           	163840              	0            	0                 	
1        	4869     	4869        	196608           	163840              	0            	0 
```

##### ndb_index_stat
Update index statistics, this is neeed bulk load of data or batch jobs modifying large portitions of the data. This is simlar to running `ANALYZE TABLE` from MySQL Client but no locking problems will be triggered on MySQL API node.
```
ndb_index_stat -d ted test --update
```
We can also look at index statistics
```
ted@speedy:~/ws-mcm$ ndb_index_stat -dted test 
table:test index:PRIMARY fragCount:2
sampleVersion:1 loadTime:1519130439 sampleCount:4868 keyBytes:19472
query cache: valid:1 sampleCount:4868 totalBytes:68152
times in ms: save: 23.329 sort: 8.527 sort per sample: 0.001
table:test index:name fragCount:2
sampleVersion:1 loadTime:1519130439 sampleCount:5030 keyBytes:44809
query cache: valid:1 sampleCount:5030 totalBytes:95109
times in ms: save: 7.478 sort: 6.207 sort per sample: 0.001
```
There are more external tools available, all tool are described [here](https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/mysql-cluster-programs.html)


**[Back to Agenda](./../README.md)**

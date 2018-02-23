**[Back to Agenda](./../README.md)**

# Lab 5 - Running some load on MySQL Cluster

There are multiple benchmark tools that you can use to test your cluster, in this workshop we will use the native myqlslap that is included with the distribution.

Benchmark tools available for MySQL Cluster can found [here](https://dev.mysql.com/downloads/benchmarks.html)
I recommend using mysqlslap for simple testing, sysbench for more advanced workloads or our flexAsync that uses native API for pushing cluster to the maximum.

mysqlslap
---------------

Mysqlslap is a simple benchmark program that works for normal MySQL and for MySQL NDB Cluster. It's a small command line tool that is part of the standard distribution and always available.

Mysqlslap have same standard options for connecting as the MySQL Client, we will run command below.
```
bash$ mysqlslap -h127.0.0.1 -P3310 -uroot -proot --auto-generate-sql --auto-generate-sql-guid-primary --auto-generate-sql-secondary-indexes=2 --auto-generate-sql-load-type=read --auto-generate-sql-write-number=200000 --auto-generate-sql-execute-number=100 --concurrency=6 --engine=ndbcluster
```
You can read about the option in the output from `mysqlslap --help` or in our [manual](https://dev.mysql.com/doc/refman/5.7/en/mysqlslap.html).

In short, mysqlslap command above will:
  - connect to one of our MySQL API nodes running on localhost using port 3310 as user "root/root",
  - then mysqlslap will generating some SQL statements,
  - we specify we want to simulate 6 sessions accessing MySQL API,
  - our test table to have 1 primary key and 2 secondary indexes,
  - furthermore we state we want to populate table with 200.000 inserts from start,
  - after data is populated the test starts by running 6 parallell 100 read request (full table scan) to our cluster table.

If you want to see what specific statements that are executed during test use option `--only-print`as last option in command above.

Low lets execute mysqlslap statement above!
```
bash$ mysqlslap -h127.0.0.1 -P3310 -uroot -proot --auto-generate-sql --auto-generate-sql-guid-primary --auto-generate-sql-secondary-indexes=2 --auto-generate-sql-load-type=read --auto-generate-sql-write-number=200000 --auto-generate-sql-execute-number=100 --concurrency=6 --engine=ndbcluster 
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
mysqlslap: Cannot run query INSERT INTO t1 VALUES (uuid(),uuid(),uuid(),964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9') ERROR : The table 't1' is full
```
Hmmm, looks like our table went full?
Lets re-run the benchmark and look at information in ndbinfo.memorysage during initial load of data.
```
mysql> select node_id, memory_type, (used/total)*100 as "Used Memory %" from ndbinfo.memoryusage;
+---------+---------------------+---------------+
| node_id | memory_type         | Used Memory % |
+---------+---------------------+---------------+
|       1 | Data memory         |       95.0000 |
|       1 | Index memory        |       33.1336 |
|       1 | Long message buffer |        0.5859 |
|       2 | Data memory         |       95.0000 |
|       2 | Index memory        |       33.1336 |
|       2 | Long message buffer |        0.5859 |
+---------+---------------------+---------------+
```
As you can see, just before mysqlslap fails we are running out of datamemory on both data nodes. Default amount of memory allocated for datamemory is 80M.
```
mcm> get -d datamemory:ndbmtd mycluster;
+------------+----------+----------+---------+----------+---------+---------+---------+
| Name       | Value    | Process1 | NodeId1 | Process2 | NodeId2 | Level   | Comment |
+------------+----------+----------+---------+----------+---------+---------+---------+
| DataMemory | 83886080 | ndbmtd   | 1       |          |         | Default |         |
| DataMemory | 83886080 | ndbmtd   | 2       |          |         | Default |         |
+------------+----------+----------+---------+----------+---------+---------+---------+
```

Lets add some more datamemory so we can run our benchmark. 
```
mcm> set datamemory:ndbmtd=160M mycluster;
```

Whilst you are waiting for configuration change to be completed you can look at rolling restart progress being completed by mcm by running:
```
watch "./mcm/bin/mcm -e'show status -r mycluster'"
```
mcm will first update configuration and restart managent nodes, next restart datanodes and lastly the MySQL API nodes.

Lets try to re-run our bechmark once more.
```
bash$ mysqlslap -h127.0.0.1 -P3310 -uroot -proot --auto-generate-sql --auto-generate-sql-guid-primary --auto-generate-sql-secondary-indexes=2 --auto-generate-sql-load-type=read --auto-generate-sql-write-number=200000 --auto-generate-sql-execute-number=100 --concurrency=6 --engine=ndbcluster 
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
	Running for engine ndbcluster
	Average number of seconds to run all queries: 118.321 seconds
	Minimum number of seconds to run all queries: 118.321 seconds
	Maximum number of seconds to run all queries: 118.321 seconds
	Number of clients running queries: 6
	Average number of queries per client: 100
``` 
During benchmark, look at memoryusage until this stop growing:
```
mysql> select node_id, memory_type, (used/total)*100 as "Used Memory %" from ndbinfo.memoryusage;
```
Also look at what cluster is doing:
```
mysql> select * from cluster_operations; SELECT * from cluster_transactions;
```
Mostly INSERT operations when datamemory is growing, we are here populating our test table, after datamemory stops growing you should see that we are doing more read (SCAN) operations.

How much CPU are our processes consuming during the benchmark?
```
mysql> select t.node_id, t.thread_name,c.OS_user,c.OS_system,c.OS_idle from cpustat c join threads t on t.node_id=c.node_id AND t.thr_no=c.thr_no order by OS_user desc;
+---------+-------------+---------+-----------+---------+
| node_id | thread_name | OS_user | OS_system | OS_idle |
+---------+-------------+---------+-----------+---------+
|       1 | ldm         |      74 |         5 |      21 |
|       2 | ldm         |      74 |         4 |      22 |
|       2 | main        |       4 |         6 |      90 |
|       1 | main        |       3 |         7 |      90 |
|       2 | recv        |       1 |         5 |      94 |
|       1 | rep         |       0 |         0 |     100 |
|       1 | recv        |       0 |         6 |      94 |
|       2 | rep         |       0 |         0 |     100 |
+---------+-------------+---------+-----------+---------+
```
During first part doing mostly inserts we are mostly using REDO and LCP capacity (I/O)
```
mysql> select * from disk_write_speed_aggregate_node\G
```
After this when doing only SCAN operations we move to being CPU bound.

Another interesting table is ndbinfo.counters, this table contains a set of counters that describes some specific action inside NDB, the counters are incremented when the action is triggered. These values are most interesting by taking two snapshopts of the statment below and them comparing them to see what has happen during the time period between the two snapshots.

```
mysql> select * from counters;
```
If you have perl installed on your server, I have created a small [perlskript](../scripts/ndbstat.pl) that takes two snapshots and prints the counters that have changed during the interal between the two snapshots.
```
bash$ perl ndbstat.pl --host=127.0.0.1 --port=3310 --user=root --password=root
```
Another option is by using a SQL file with two select statements and a sleep in between like [this](../scripts/counter-stats.sql) and run it via `watch`:
```
bash$ watch "mysql -uroot -proot -h127.0.0.1 -P3310 < counter-stats.sql"
```
Re-run benchmark and look at counters table.

Extras (not part of 1-day workshop)
-------------
#### flexAsynch

To build flexAsynch you need to download our source code either from [gitub](https://github.com/mysql/mysql-server) or via link below.  
You can view the code for flexAsynch on gitub [here](https://github.com/mysql/mysql-server/blob/5.7/storage/ndb/test/ndbapi/flexAsynch.cpp).
```
 wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.5/mysql-cluster-gpl-7.5.9.tar.gz
 tar xzf mysql-cluster-gpl-7.5.9.tar.gz
 cd mysql-cluster-gpl-7.5.9
```
Build the flexAsynch binaries.
(you need to have cmake,g++, gcc, cmake, libncurses5-dev build binaries)
(replace my paths with your own before running the commands)
```
mkdir 759Target
cmake . -DCMAKE_INSTALL_PREFIX=/path/to/759target/ -DWITH_NDB_TEST=ON
             -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/path/to/build/mysql-cluster-gpl-7.5.9/boost/
make
make install
```
Running flexAsynch
(replace path and HOST:PORT with hostname and port nuumber (1186 default) to your management node before running commands)
```
export LD_LIBRARY_PATH=/path/to/759Target/lib
export NDB_CONNECTSTRING="host=HOST:PORT"
./flexAsynch -temp -t 1 -p 80 -l 2 -o 100 -c 100 -n -a 2
```
If you get an error that you can not allocate a node id this means you have no free slots to connect to the cluster. Add another slot in you configuration by running command below (replace <ip-address> and <clustername>).
```
mcm: add process --processhosts=ndbapi@<ip-adress> <cluster-name>;
```

**[Back to Agenda](./../README.md)**

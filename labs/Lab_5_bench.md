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

In short, we will connect to one of the MySQL API nodes running on localhost, port 3310 as "user/pwd" "root/root", we will then have mysqlslap generating some SQL statements, we specify we want to simulate 6 sessions accessing MySQL API, our test table to have 1 primary key and 2 secondary indexes, furthermore we state we want to populate table with 200.000 inserts from start, and this we will start test by running 6 parallell 100 read request (full table scan) to our cluster table.

If you want to see what statements are executed during test add option `--only-print`as last option to command above.

Low lets execute mysqlslap statement above!
```
bash$ mysqlslap -h127.0.0.1 -P3310 -uroot -proot --auto-generate-sql --auto-generate-sql-guid-primary --auto-generate-sql-secondary-indexes=2 --auto-generate-sql-load-type=read --auto-generate-sql-write-number=200000 --auto-generate-sql-execute-number=100 --concurrency=6 --engine=ndbcluster 
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
mysqlslap: Cannot run query INSERT INTO t1 VALUES (uuid(),uuid(),uuid(),964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9') ERROR : The table 't1' is full
```
Looks like our table is full?
Lets re-run the benchmark and look at information in ndbinfo.memorysage during initial load of data.
```

```

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

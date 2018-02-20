**[Back to Agenda](./../README.md)**

# Lab 5 - Running some load on MySQL Cluster

There are multiple benchmark tools that you can use to test your cluster, in this workshop we will use the native myqlslap that is included with the distribution.

Benchmark tools available for MySQL Cluster can found [here](https://dev.mysql.com/downloads/benchmarks.html)
I recommend using mysqlslap for simple testing, sysbench for more advanced workloads or our flexAsync that uses native API for pushing cluster to the maximum.


NDBINFO tables
---------------
Not all tables of the NDBINFO schema will be explained below, we will cover the most frequeltly used ones but all of them are important to understand in a production environment.

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
Lets find some information about our test table created above, if you want to filer out some schemas or tables add where clause to statement and filter on fq_name, format of fq_name is \<schema\>/def/\<table\> as seen for our test table below.
```
mysql> select * from dict_obj_info where fq_name='ted/def/test';                   
+------+------+---------+-------+-----------------+---------------+--------------+
| type | id   | version | state | parent_obj_type | parent_obj_id | fq_name      |
+------+------+---------+-------+-----------------+---------------+--------------+
|    2 |   10 |       1 |     4 |               0 |             0 | ted/def/test |
+------+------+---------+-------+-----------------+---------------+--------------+
```
Extras (not part of 1-day workshop)
-------------
#### flexAsynch

To build flexAsynch you need to download our source code.
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

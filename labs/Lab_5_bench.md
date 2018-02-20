**[Back to Agenda](./../README.md)**

# Lab 5 - Benchmarking a MySQL Cluster

Monitoring NBD Cluster can be done by using [MySQL Enterprise Monitor](https://www.mysql.com/products/enterprise/monitor.html). MySQL Enterprise Monitor is a graphical monitoring system that can be used to get a high level view of your cluster status, it can also fire off alarms if something is not working correctly.

Low level diagnostics on what is happening in MySQL cluster is available via a set of tables in the `ndbinfo` schema. All tables in `ndbinfo` schema are described in detail in our [manual](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-ndbinfo.html). 

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

**[Back to Agenda](./../README.md)**

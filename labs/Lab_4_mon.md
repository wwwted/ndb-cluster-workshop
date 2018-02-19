**[Back to Agenda](./../README.md)**

# Lab 4 - Monitoring a MySQL Cluster

Monitoring NBD Cluster can be done by using [MySQL Enterprise Monitor](https://www.mysql.com/products/enterprise/monitor.html). MySQL Enterprise Monitor is a graphical monitoring system that can be used to get a high level view of your cluster status, it can also fire off alarms if something is not working correctly.

Low level diagnostics on what is happening in MySQL cluster is available via a set of tables in the `ndbinfo` schema. All tables in `ndbinfo` schema are described in detail in our [manual](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-ndbinfo.html). 

#### NDBINFO tables

Start the MySQL client (If you want to see help run `mysql --help`)

```
mysql -uroot -proot ndbinfo
```


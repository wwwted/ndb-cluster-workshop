**[Back to Agenda](./../README.md)**

# Lab 6 - Increase capacity of the cluster

There are mainly two ways to scale the capacity of your cluster, you can scale out or scale up. Scaling out means adding more data nodes to your cluster, scaling up means adding more capacity to your existing data nodes (and adding more (LDM/TC) processes to utilize the additional resources). 

Reasons for scaling out/up might be:
  - handle a larger database footprint, current memory capacity of your data nodes (LDM) is not enough
  - handle increased load to the cluster.

Add more data nodes to the cluster
---------------

Before we add more data nodes, lets look at distribution of data in our test table in database ted.
```
bash$ ndb_desc -pn -dted -p test
```
If you need to re-create the test table run command below, code for [create_ndb_testdata.sql](https://gist.github.com/wwwted/10656c765dac2c988ba567d5c710c7e6).
```
mysql -uroot -h127.0.0.1 -P3310 -proot < create_ndb_testdata.sql
```

**[Back to Agenda](./../README.md)**

**[Back to Agenda](./../README.md)**

# Lab 7 - Adding Geographic redundancy to MySQL Cluster

With MySQL Cluster you have two options to achieve geographic redundancy, either you create 2 MySQL Cluster sites in different locations and use MySQL asynchronous replication to keep them in sync or you 'streach' one installation of one cluster over 2 locations separated by some distance.

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
##### One streached cluster
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

TBC ...

Creating two 2 cluster with replication
---------------

#### Active/Passive setup

#### Active/Active setup anf conflict resolution


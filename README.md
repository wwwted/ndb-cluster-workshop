Welcome to the MySQL NDB Cluster Workshop!
===================
![icon](https://upload.wikimedia.org/wikipedia/en/thumb/6/62/MySQL.svg/124px-MySQL.svg.png)

In this workshop, you will learn about MySQL Cluster. This workshop is a blend of presentation and hands-on work.
The presentations can be found in [docs](./docs) folder and hands on work in [labs](./labs) folder. There are some small scripts that are usefull for looking at data in ndbinfo in the [scripts](./scripts) folder.
Feel free to bookmark (star) this page for future testing.

To fully benefit (not mandatory) from hands-on work in this workshop its important that you have some prior experience with databases and are comfortable working in a Linux/Unix environment.

If you want to attend the hands-on work you need to download MCM (Mysql Cluster Manager) as described [here](/labs/prework.md).  
MySQL Cluster Manager [cheat sheet](https://gist.github.com/wwwted/fb151c3a14c3e9ba65fe0f09ed65a1c4), complete list of commands is available in our online [reference manual](https://dev.mysql.com/doc/mysql-cluster-manager/1.4/en/mcm-client-commands.html).

----------


Agenda for today:

* Introduction: Architecture
  * Lecture 

* Getting Started: configuration/install/start/stop
  * Lecture
  * [Lab 1 - Install MySQL Cluster Manager](./labs/Lab_1_install.md)
  * [Lab 2 - Create Cluster](./labs/Lab_2_create.md)

* Administration: Backup/upgrade/logs/conf/sizing
  * Lecture
  * [Lab 3 - Backup](./labs/Lab_3_backup.md)

* Monitoring: Surveillance and problem solving
  * Lecture
  * [Lab 4 - Monitoring](./labs/Lab_4_mon.md)
  * [Lab 5 - Benchmark](./labs/Lab_5_bench.md)
  * [Lab 6 - Add more capacity](./labs/Lab_6_add.md)

* Best practices: Architectures and case studies
  * Lecture

* Geo Replication: Asynchronous replication and conflict resolution
  * Lecture
  * Not part of 1-day workshop [Lab 5 - Replication](./labs/Lab_4_replication.md)
 
 --------
 
 If you want to know more about MySQL Cluster I recommend looking at these 2 books:
- [Pro MySQL NDB Cluster](https://www.apress.com/br/book/9781484229811)
- [MySQL Cluster 7.5 inside and out](https://www.adlibris.com/se/bok/mysql-cluster-75-inside-and-out-mysql-cluster-75-inside-and-out-9789176997574)

Our MySQL Cluster blogs and manuals:
- [MySQL Cluser Carrier Grade Edition](https://www.mysql.com/products/cluster/) 
- [Reference manual for NDB 7.5](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster.html)
- [Mikael Ronstroms blog, the creator of NDB](http://mikaelronstrom.blogspot.co.uk/)
- [MySQL HA Blog](https://mysqlhighavailability.com/category/mysql-cluster/)

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
...
PartitionCount: 2
FragmentCount: 2
PartitionBalance: FOR_RP_BY_LDM
...
HashMap: DEFAULT-HASHMAP-3840-2
...
-- Per partition info -- 
Partition	Row count	Commit count	Frag fixed memory	Frag varsized memory	Extent_space	Free extent_space	Nodes	
0         	5031     	5031        	196608           	163840              	0            	0                 	1,2	
1        	4869     	4869        	196608           	163840              	0            	0                 	2,1	
```
If you need to re-create the test table run command below (code for [create_ndb_testdata.sql](https://gist.github.com/wwwted/10656c765dac2c988ba567d5c710c7e6)).
```
mysql -uroot -h127.0.0.1 -P3310 -proot < create_ndb_testdata.sql
```
As shown above all data in table test is stored in 2 partitions on data nodes 1 and 2.

Lets add 2 more data nodes.
```
mcm> add process --processhosts=ndbmtd@127.0.0.1,ndbmtd@127.0.0.1 mycluster;
```
Look at new cluster arhitecure.
```
mcm> show status -r mycluster;
+--------+----------+------------+-----------+-----------+------------+
| NodeId | Process  | Host       | Status    | Nodegroup | Package    |
+--------+----------+------------+-----------+-----------+------------+
| 49     | ndb_mgmd | 127.0.0.1  | running   |           | cluster758 |
| 1      | ndbmtd   | 127.0.0.1  | running   | 0         | cluster758 |
| 2      | ndbmtd   | 127.0.0.1  | running   | 0         | cluster758 |
| 3      | ndbmtd   | 127.0.0.1  | added     | n/a       | cluster758 |
| 4      | ndbmtd   | 127.0.0.1  | added     | n/a       | cluster758 |
| 50     | mysqld   | 127.0.0.1  | running   |           | cluster758 |
| 51     | mysqld   | 127.0.0.1  | running   |           | cluster758 |
| 52     | ndbapi   | *127.0.0.1 | added     |           |            |
| 53     | ndbapi   | *127.0.0.1 | added     |           |            |
| 54     | ndbapi   | *127.0.0.1 | connected |           |            |
| 55     | ndbapi   | *127.0.0.1 | connected |           |            |
+--------+----------+------------+-----------+-----------+------------+

```
We can now see that we have added two more data nodes, but they are not started, lets start the two new data nodes.
```
mcm> start process --added mycluster;
```
Lets looks at distrubution of data for table ted.test again.
```
bash$ ndb_desc -pn -dted -p test
...
PartitionCount: 2
FragmentCount: 2
PartitionBalance: FOR_RP_BY_LDM
...
HashMap: DEFAULT-HASHMAP-3840-2
...
-- Per partition info -- 
Partition	Row count	Commit count	Frag fixed memory	Frag varsized memory	Extent_space	Free extent_space	Nodes	
0         	5031     	5031        	196608           	163840              	0            	0                 	1,2	
1        	4869     	4869        	196608           	163840              	0            	0                 	2,1	
```
Exactly the same as before, do not worry, this is not an error, we do not re-organize data automatically for existing tables, this is an manual process. That said, all new tables created after we added the new data nodes will leverage all data nodes.

Lets re-organize data for table ted.test.
```
mysql> ALTER TABLE ted.test REORGANIZE PARTITION;
```
Lets looks at distrubution of data for table ted.test again.
```
bash$ ndb_desc -pn -dted -p test
...
PartitionCount: 4
FragmentCount: 4
PartitionBalance: FOR_RP_BY_LDM
...
HashMap: DEFAULT-HASHMAP-3840-4
...
-- Per partition info -- 
Partition	Row count	Commit count	Frag fixed memory	Frag varsized memory	Extent_space	Free extent_space	Nodes	
0         	2534     	10025       	196608           	163840              	0            	0                 	1,2	
1        	2379     	9849        	196608           	163840              	0            	0                 	2,1	
2        	2497     	2497        	98304            	98304               	0            	0                 	3,4	
3        	2490     	2490        	98304            	98304               	0            	0                 	4,3	
```
Now we can see that data is spread over all 4 partition and row count is quite evenly spred over all data nodes.  

Great work!

**[Back to Agenda](./../README.md)**

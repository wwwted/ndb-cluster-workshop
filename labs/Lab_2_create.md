
**[Back to Agenda](./../README.md)**

# Lab 2 - Create a MySQL Cluster

In this exercise we are going to configure and start the cluster. This can be done from any server, even remotely as long as you can connect to one of the mcmd daemons running on your cluster servers installed earlier.

###  Configure our Cluster using MCM

Start the mcm client
If you want to see help run `./mcm/bin/mcm --help`
Our reference manual can be found [here](https://dev.mysql.com/doc/mysql-cluster-manager/1.4/en/mcm-cluster-commands.html).

```
./mcm/bin/mcm
```

If you want mcm client to remotely connect to a mcmd daemon you can provide option `-a`, the argument to provide is `host:port`. For above client connect we can use `./mcm/bin/mcm -a localhost:1862` and provide default values if we want.


Once connected you can look at all commands available by running:
```
mcm> list commands;
```

First step before we can start configuring our cluster is to create a site that contains all the hosts that will be part of our cluster. In our simple demo we only have one host (localhost or 127.0.0.01) and lets call our site `mysite`.
```
mcm> create site --hosts=127.0.0.1 mysite;
```

To see what sites you have already created and list hosts at those sites use commands below
```
mcm> list sites;
mcm> list hosts mysite;
```

Next step is to add the NDB Cluster binaries (called packade in mcm) to our site so we can start configuring our cluster. The arguments you are providing are the search path to the base folder of the binareies and a alias name to be user internally when refering to the package, lets call them cluster758 (or whatever version number you installed).
```
mcm> add package --basedir=/home/<user>/MCM_LAB/cluster-758 cluster758;
```

You can have many different packages added to your sites, you can also have different clusters using different packages, to list the packages you have available use commmand:
```
mcm> list packages mysite;
```
Next step is to create our cluster, this is done with the `create cluster` command, we will need to provide a package, the different processes we want to create (and their location) and set a name of our cluster.
Lets use the package we created earlier called `cluster758` and lets name our cluster mycluster.
The argument `--processhosts` takes a list of `processtype@host`as argument, the type of processes are ndb, ndbmtd, ndb_mgmd, mydsqld and api.

We will create a cluster with below processsed all running on local server (127.0.0.1):
- 1 management node (ndb_mgmd)
- 2 data nodes (ndbmtd)
- 2 MySQL API nodes (mysqld)
- 4 API slots for any process to connect (we will use these for tools later on)
```
mcm> create cluster --package=cluster758 --processhosts=ndb_mgmd@127.0.0.1,ndbmtd@127.0.0.1,ndbmtd@127.0.0.1 mycluster;
mcm> add process --processhosts=mysqld@127.0.0.1,mysqld@127.0.0.1 mycluster;
mcm> add process --processhosts=ndbapi@127.0.0.1,ndbapi@127.0.0.1 mycluster;
mcm> add process --processhosts=ndbapi@127.0.0.1,ndbapi@127.0.0.1 mycluster;
```

As we are added 2 MySQL API nodes we need to make sure they have their own unique port numbers, lets assign port number 3310 to the first mysqld and 3311 to the second one.

You might wonder about the number `50`and `51`, these are so called Node ID that are used to identify different processed within a cluster. First 48 Node ID's are pre-allocated to data nodes (ndbmtd), then there is a range of 49-255 available for others. In our cluster the data nodes will get Node ID `1` and `2`, the management node will get ID `49`and the two mysql nodes `50` and `51`. You can also specify Node ID when creating your cluster using the `create cluster` command.
```
mcm> set port:mysqld:50=3310 mycluster;
mcm> set port:mysqld:51=3311 mycluster;
```

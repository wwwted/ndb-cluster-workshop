
**[Back to Agenda](./../README.md)**

# Lab 2 - Create a MySQL Cluster

In this exercise we are going to configure and start the cluster. This can be done from any server, even remotely as long as you can connect to one of the mcmd daemons running on your cluster servers installed earlier.

**Attention:**
  Remember to set the PATH env varaible manualy or by using `bash>. ./setenv` before trying to start mcm client, mcm client need to find the mysql client.

#### The MCM client

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

#### Configure Cluster

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

We will create a cluster with below processses, all processes running on local server (127.0.0.1):
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

#### Start Cluster

Before we start the cluster, look at layout of the configured cluster.
```
mcm> show status -r mycluster;
```
We can also look at all parameters set in configuration.
```
mcm> get mycluster;
```
If all looks good lets go ahead and start the cluster.
```
mcm> start cluster --background mycluster;
```
Now we can run:
```
mcm> show status -r mycluster;
mcm> show status --progress mycluster;
mcm> show status --progressbar mycluster;
```
And see how the processes are starting.
Once all processes have started you should see `Status` being `Running` for the management, data and MySQL nodes as shown below.
```
mcm> show status -r mycluster;
+--------+----------+------------+---------+-----------+------------+
| NodeId | Process | Host        | Status  | Nodegroup | Package    |
+--------+----------+------------+---------+-----------+------------+
| 49     | ndb_mgmd | 127.0.0.1  | running |           | cluster758 |
| 1      | ndbmtd   | 127.0.0.1  | running | 0         | cluster758 |
| 2      | ndbmtd   | 127.0.0.1  | running | 0         | cluster758 |
| 50     | mysqld   | 127.0.0.1  | running |           | cluster758 |
| 51     | mysqld   | 127.0.0.1  | running |           | cluster758 |
| 52     | ndbapi   | *127.0.0.1 | added   |           |            |
| 53     | ndbapi   | *127.0.0.1 | added   |           |            |
| 54     | ndbapi   | *127.0.0.1 | added   |           |            |
| 55     | ndbapi   | *127.0.0.1 | added   |           |            |
+--------+----------+------------+---------+-----------+------------+
```
After our cluster is up and running it's time to set some passwords for MySQL API nodes
```
./cluster-758/bin/mysqladmin -h127.0.0.1 -P3310 -uroot password 'root'
./cluster-758/bin/mysqladmin -h127.0.0.1 -P3311 -uroot password 'root'
```

#### Automate the configuration/start of cluster (Not part of workshop)
We can put all MCM commands in one file:
```
create site --hosts=127.0.0.1 mysite;
add package --basedir=/home/<user>/MCM_LAB/cluster-758 cluster758;
create cluster --package=cluster758 --processhosts=ndb_mgmd@127.0.0.1,ndbmtd@127.0.0.1,ndbmtd@127.0.0.1 mycluster;
add process --processhosts=mysqld@127.0.0.1,mysqld@127.0.0.1 mycluster;
add process --processhosts=ndbapi@127.0.0.1,ndbapi@127.0.0.1 mycluster;
add process --processhosts=ndbapi@127.0.0.1,ndbapi@127.0.0.1 mycluster;
set port:mysqld:50=3310 mycluster;
set port:mysqld:51=3311 mycluster;
```
Copy commands above into a file mcm.cmds or download file from [here](https://gist.github.com/wwwted/1ee83009d7344c1348aae41df655d839).

This file can be put in any version handling system and be part of your prefered deployment framework.
Run the file with mcm commands using the mcm client like:
```
mcm -a host:port < mcm.cmds
```

#### Finding your way around the environment
The cluster data for cluster processes are installed under folder `./mcm_data/clusters/`.
Structure is:
```
mcd_data/
        clusters/
                 mycluster/
                           <Process NodeID>
                                           data/
                                           logs/
                                           tmp/
                           ...
```
Node ID's for processes in our cluster are shown by running command `show status -r mycluster`

The central cluster logfile can be located in directory for management node (Node-ID 49) `mcm_data/clusters/mycluster/49/data/ndb_49_cluster.log`

Other local log files for the processes of our cluster are located under `data/` folder for each process.

#### Handling the configuration after initial install
You should never attempt to alter the local configuration files directly, this will break your cluster. Use `set/get` commands to work with configuration of your Cluser. MCM will take of any needed restarts due to changing a configuration parameter. Type of cluster restart needed for configuration changes is dependant on the parameter, you can see all data node parameters [here](https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-params-ndbd.html), under section **Restart Type** your will see restart type needed.

Look at configuration parameters configured for the cluster
```
mcm> get mycluster;
```
By adding options `-d` mcm wil also print all configarion (parameters using default values).
```
mcm> get -d mycluster;
```
You can retrieve all values for specific type of processes by adding process type to the `get` command
```
mcmd> get :ndbmtd mycluster;
```
Types of processes can be `mysql | ndbmtd | ndb_mgm`

If you know the name of the parameter you can specify this also directly like:
```
mcm> get -d FragmentLogFileSize:ndbmtd mycluster;
```

If you are only interested in a parameter for a specific process you can add Node-ID after processtype like:
```
mcm> get port:mysqld mycluster;
mcm> get port:mysqld:50 mycluster;
```

To update the configuration we use the `set` command. The syntax is similar to `get` command above.
```
mcm> set <PARAM>:[ndbmtd|mysqld|ndb_mgmd]=<VALUE> mycluster;
```
You can set multiple parameters in one commands to avoid multiple restarts. 
```
mcm> set <PARAM>:[PROCESS_TYPE]=<VALUE>,<PARAM>:[PROCESS_TYPE]=<VALUE> mycluster;
```
Set *MemReportFrequency* to 10 and *FragmentLogFileSize* to 24M for both NDBMTD, look in main cluster log that reports are  being written and also look at size of log files on disk.
```
mcm> set FragmentLogFileSize:ndbmtd=24M,MemReportFrequency:ndbmtd=10 mycluster;
```
You can monitor the progress of restart by running:
```
mcm> show status --progress mycluster
mcm> show status --progressbar mycluster;
```
Above `show status --progress` command can be used to see progress for many ohter commands in MCM also.

Set *MemReportFrequency* parameter back to default (0).

**[Back to Agenda](./../README.md)**


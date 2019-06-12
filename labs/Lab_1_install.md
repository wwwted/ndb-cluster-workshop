**[Back to Agenda](./../README.md)**

# Lab 1 - Install MySQL Cluster

In this exercise we are going to create our environment, configure and start mcm daemon. Next steps will be to configure and start our cluster.

Steps below need to be done on all servers that are to be part of the MySQL Cluster, in this workshop we run the complete cluster on one server but for a production environment you would need at least 3 servers and need to do the installation as described below on all 3 servers.

### Target environment for HOL
```
/home/<user>/ndb-cluster-workshop/
                     cluster-7XX/ (replace X with real version number)
                     mcm1.X.X/
                     ndb_bin -> /home/<user>/MCM_LAB/cluster-7XX/
                     mcm_bin -> /home/<user>/MCM_LAB/mcm1.X.X
                     mcm_data/
                     scripts/
                     tools/
                     mcm-templates/
                     docs/
                     mcmd.ini
                     setenv
```

### 1. Install MySQL Cluster and MySQL Cluster Manager aka "MCM"
(code snip for creating environment [here](https://gist.github.com/wwwted/62406be3a6863d28534e1dbf3249b396))

Dowload workshop from github:
```
git clone https://github.com/wwwted/ndb-cluster-workshop.git
```
Prior to running createEnv.sh you need to download all needed SW (NDB binaries and MCM binaries) and change parameter "BIN_DIR" to where the tar.gz binary packages are located.
Go into workshop folder and run script tools/createEnv.sh
```
cd ndb-cluster-workshop
./tools/createEnv.sh
```
You will need to run below command (or manually set the PATH) in all terminals before trying to access mcm or ndb binaries otherwice it will not work. Below command also set an environment varieble used by other scripts so run setenv before running any scripts/tools included in workshop.
```
bash> . ./setenv
```

Verify that setenv worked by running:
```
bash$ which mysql
bash$ which mcm
bash$ env | grep PATH
bash$ env | grep WS
```

Start MCM daemon (mcmd)
```
mcmd --defaults-file=./mcmd.ini --daemon
```

Grep for mcmd process and inspect end of log file and verify that mcmd started okay.
```
ps -wwaux | grep mcmd | grep -v grep
tail -50 mcmd.log
```

If you want to start over you can run:
```
./scripts/reset.sh
```
This will remove all created cluster and content in mcm_data

**[Back to Agenda](./../README.md)**

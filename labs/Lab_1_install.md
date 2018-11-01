**[Back to Agenda](./../README.md)**

# Lab 1 - Install MySQL Cluster

In this exercise we are going to create our environment, configure and start mcm daemon. Next steps will be to configure and start our cluster.

Steps below need to be done on all servers that are to be part of the MySQL Cluster, in this workshop we run the complete cluster on one server but for a production environment you would need at least 3 servers and need to do the installation as described below on all 3 servers.

### Target environment for HOL
```
/home/<user>/MCM_LAB/
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

Create a folder for the workshop
```
mkdir MCM_LAB
cd MCM_LAB
```

Dowload workshop from github:
```
git clone https://github.com/wwwted/ndb-cluster-workshop.git
```

Copy tools, scripts and other material from git folder to MCM_LAB and remove the rest:
```
cp -fr ndb-cluster-workshop/scripts .
cp -fr ndb-cluster-workshop/tools/ .
cp -fr ndb-cluster-workshop/mcm-templates .
cp -fr ndb-cluster-workshop/docs .
cp -f  ndb-cluster-workshop/setenv .
rm -fr ndb-cluster-workshop
```

Extract mysql cluster manager and cluster binaries from tar files
(first step is to unzip tar packages from tar files)
```
tar xzf /path/to/cluster/binaries/mysql-cluster-advanced-7.5.X-linux-glibc2.12-x86_64.tar.gz
tar xzf /path/to/cluster/binaries/mcm-1.4.X-linux-glibc2.12-x86-64bit.tar.gz
```

Rename cluster binaries to cluster-75X (replace X with real version number)
```
mv mysql-cluster-advanced-7.5.X-linux-glibc2.12-x86_64.tar.gz cluster-75X
```

Move MCM binaries folder to $MCM_LAB (replace X with real version number)
```
mv mcm-1.4.X-linux-glibc2.12-x86-64bit/mcm1.4.X .
rmdir mcm-1.4.X-linux-glibc2.12-x86-64bit
```

Create a soft link called only `mcm_bin` that point to folder mcm1.4.X like
```
ln -s mcm1.4.X mcm_bin
```
You should se the folowing folders under mcm catalogue:
```
bash$ ls mcm/
bin  etc  lib  libexec  licenses  share  var
```

Create a soft link to ndb binaries like:
```
ln -s  cluster-75X ndb_bin
```

Move MCM configuration file to $MCM_LAB top folder (replace X with real version number)
```
cp mcm/etc/mcmd.ini .
```

Edit MCM configuration before starting MCM daemon, manager-directory should be path to your MCM repository, you do not have to create the folder "mcm_data" as this is done at first start by mcmd.
```
manager-directory = /home/<user>/MCM_LAB/mcm_data
```

Update the setenv file if needed so PATH variable is correct (depends on version of cluster installed)
```
export WS_HOME=$PWD
export PATH=${WS_HOME}/cluster-758/bin:${WS_HOME}/mcm/bin:$PATH
```
(remember to exchange version numbers if neeed) 
You will need to run below command (or manually set the PATH) in all terminals before trying to access mcm otherwice it will not be able to locate mysql client and mcm.
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

Start MCM daemon (mcmd) (replace X with real version number)
```
./mcm/bin/mcmd --defaults-file=./mcmd.ini --daemon
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

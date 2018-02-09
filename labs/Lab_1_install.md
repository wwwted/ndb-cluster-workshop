**[Back to Agenda](./../README.md)**

# Lab 1 - Install MySQL Cluster

In this exercise we are going to create our environment, start mcm and configure our cluster.

### Target environment for HOL
```
/home/<user>/MCM_LAB/
                     cluster-75X/ (replace X with real version number)
                     mcm1.4.X/
                     mcm_data/
                     mcmd.ini
```

### 1. Install MySQL Cluster and MySQL Cluster Manager aka "MCM"
Create a folder for the workshop
```
mkdir MCM_LAB
cd MCM_LAB
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

Move MCM configuration file to $MCM_LAB top folder (replace X with real version number)
```
cp /mcm1.4.X/etc/mcmd.ini .
```

Edit MCM configuration before starting MCM daemon, manager-directory should be path to your MCM repository, you do not have to create the folder "mcm_data" as this is done at first start by mcmd.
```
manager-directory = /home/<user>/MCM_LAB/mcm_data
```
Start MCM daemon (mcmd) (replace X with real version number)
```
./mcm1.4.X/bin/mcmd --defaults-file=./mcmd.ini --daemon
```
Grep for mcmd process and inspect end of log file and verify that mcmd started okay.
```
ps -wwaux | grep ssh | grep -v grep
tail -50 mcmd.log
```

### 2. Configuring MySQL Cluster

**[Back to Agenda](./../README.md)**

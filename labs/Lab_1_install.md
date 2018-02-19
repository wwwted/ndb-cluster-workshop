**[Back to Agenda](./../README.md)**

# Lab 1 - Install MySQL Cluster

In this exercise we are going to create our environment, configure and start mcm daemon. Next steps will be to configure and start our cluster.

Steps below need to be done on all servers that are to be part of the MySQL Cluster, in this workshop we run the complete cluster on one server but for a production environment you would need at least 3 servers and need to do the installation as described below on all 3 servers.

### Target environment for HOL
```
/home/<user>/MCM_LAB/
                     cluster-75X/ (replace X with real version number)
                     mcm1.4.X/
                     mcm -> /home/<user>/MCM_LAB/mcm1.4.X
                     mcm_data/
                     mcmd.ini
                     setenv
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

Create a soft link called only `mcm` that point to folder mcm1.4.X like
```
ln -s mcm1.4.X mcm
```
You should se the folowing folders under mcm catalogue:
```
bash$ ls mcm/
bin  etc  lib  libexec  licenses  share  var
```

Move MCM configuration file to $MCM_LAB top folder (replace X with real version number)
```
cp mcm/etc/mcmd.ini .
```

Edit MCM configuration before starting MCM daemon, manager-directory should be path to your MCM repository, you do not have to create the folder "mcm_data" as this is done at first start by mcmd.
```
manager-directory = /home/<user>/MCM_LAB/mcm_data
```

Create simple file to set the path to the binaries, name it `setenv` and put it in your MCM_LAB/ folder
```
EXPORT PATH=/home/<user>/MCM_LAB/cluster-75X/bin:/home/<user>/MCM_LAB/mcm/bin:$PATH
```
(remember to exchange `<user>` and version numbers above with real values) 
You will need to run below command (or manually set the PATH) in all terminals before trying to access mcm otherwice it will not be able to locate mysql client.
```
bash> . ./setenv
```

Start MCM daemon (mcmd) (replace X with real version number)
```
./mcm/bin/mcmd --defaults-file=./mcmd.ini --daemon
```

Grep for mcmd process and inspect end of log file and verify that mcmd started okay.
```
ps -wwaux | grep ssh | grep -v grep
tail -50 mcmd.log
```

**[Back to Agenda](./../README.md)**

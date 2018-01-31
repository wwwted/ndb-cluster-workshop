  **[Back to Agenda](./../README.md)**

# Lab 1 - Install MySQL Cluster

In this exercise we are going to create our environment, start mcm and configure our cluster.

### Target environment for HOL
```
/home/<user>/MCM_LAB/
                     cluster-75X/ (replace X with real version number)
                     cluster-75X/ (replace X with real version number)
                     mcm1.4.X/
                     mcm_data/
                     mcmd.ini
```

### Install MySQL Cluster and MCM
Create a folder for the workshop
```
mkdir MCM_LAB
cd MCM_LAB
```

Extract mysql cluster manager and cluster binaries from tar files
(first step is to unzip tar packages from tar files)
```
tar xzf /path/to/cluster/binaries/
tar xzf /path/to/cluster/binaries/
tar xzf /path/to/cluster/binaries/mcm-1.4.X-linux-glibc2.12-x86-64bit.tar.gz
```

Rename cluster binaries to cluster-75X and cluster-75X (replace X with real version number)
```
mv 
mv
```

• mv mcm-1.3.3-linux-glibc2.5-x86-64bit/mcm1.3.3 .
• rmdir mcm-1.3.3-linux-glibc2.5-x86-64bit
• cp /mcm1.3.3/etc/mcmd.ini .
• Change manager-directory in mcmd.ini to /home/<user>/MCM_LAB/mcm_data
• Start mcmd:
./mcm1.3.3/bin/mcmd --defaults-file=./mcmd.ini --daemon

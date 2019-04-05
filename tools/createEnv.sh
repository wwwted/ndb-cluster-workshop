#!/bin/bash
# wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-gpl-7.6.9-linux-glibc2.12-x86_64.tar.gz
# Download MCM by following my guide on Github here: https://github.com/wwwted/ndb-cluster-workshop/blob/master/labs/prework.md

# Download NDB 7.6.9 and MCM 1.4.7 + change BIN_DIR to folder with binaries in tar.gz format.
# TARGET_DIR is where you downloaded the workshop (git clone https://github.com/wwwted/ndb-cluster-workshop.git)
TARGET_DIR="/home/ted/ndb-cluster-workshop"
BIN_DIR="/home/ted/src"

# You should not have to change anything below ;)
cd $TARGET_DIR

tar xzf $BIN_DIR/mysql-cluster-gpl-7.6.9-linux-glibc2.12-x86_64.tar.gz
tar xzf $BIN_DIR/mcm-1.4.7-linux-glibc2.12-x86-64bit.tar.gz

mv mysql-cluster-gpl-7.6.9-linux-glibc2.12-x86_64 cluster-769

mv mcm-1.4.7-linux-linux-glibc2.12-x86-64bit/mcm1.4.7 .
rmdir mcm-1.4.7-linux-linux-glibc2.12-x86-64bit
ln -s mcm1.4.7/ mcm_bin
ln -s cluster-769 ndb_bin

cp mcm_bin/etc/mcmd.ini .
echo "manager-directory = $TARGET_DIR/mcm_data" >> $TARGET_DIR/mcmd.ini
sed "s|log-file.*|log-file=$TARGET_DIR\/mcmd.log|" < $TARGET_DIR/mcmd.ini > $TARGET_DIR/mcmd.ini_tmp
mv $TARGET_DIR/mcmd.ini_tmp $TARGET_DIR/mcmd.ini
chmod 660 $TARGET_DIR/mcmd.ini

echo "export WS_HOME=$TARGET_DIR" > $TARGET_DIR/setenv
echo "export PATH=$TARGET_DIR/ndb_bin/bin:$TARGET_DIR/mcm_bin/bin:$PATH" >> $TARGET_DIR/setenv

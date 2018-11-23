#!/bin/bash
# wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.5/mysql-cluster-gpl-7.5.12-linux-glibc2.12-x86_64.tar.gz

TARGET_DIR="/home/ted/MCM_LAB2"
BIN_DIR="/home/ted/src"

cd $TARGET_DIR

tar xzf $BIN_DIR/mysql-cluster-gpl-7.5.12-linux-glibc2.12-x86_64.tar.gz
# tar xzf $BIN_DIR/mysql-cluster-gpl-7.5.9-linux-glibc2.12-x86_64.tar.gz
tar xzf $BIN_DIR/mcm-1.4.6-linux-glibc2.12-x86-64bit.tar.gz

mv mysql-cluster-gpl-7.5.12-linux-glibc2.12-x86_64 cluster-7512
# mv mysql-cluster-gpl-7.5.9-linux-glibc2.12-x86_64/ cluster-759

mv mcm-1.4.6-linux-glibc2.12-x86-64bit/mcm1.4.6 .
rmdir mcm-1.4.6-linux-glibc2.12-x86-64bit
ln -s mcm1.4.6/ mcm_bin
ln -s cluster-7512 ndb_bin

cp mcm_bin/etc/mcmd.ini .
echo "manager-directory = $TARGET_DIR/mcm_data" >> $TARGET_DIR/mcmd.ini
sed "s|log-file.*|log-file=$TARGET_DIR\/mcmd.log|" < $TARGET_DIR/mcmd.ini > $TARGET_DIR/mcmd.ini_tmp
mv $TARGET_DIR/mcmd.ini_tmp $TARGET_DIR/mcmd.ini
chmod 660 $TARGET_DIR/mcmd.ini

echo "export WS_HOME=$TARGET_DIR" > $TARGET_DIR/setenv
echo "export PATH=$TARGET_DIR/ndb_bin/bin:$TARGET_DIR/mcm_bin/bin:$PATH" >> $TARGET_DIR/setenv

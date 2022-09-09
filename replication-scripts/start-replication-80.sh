#!/bin/bash
#
# 1) Start 2 Cluster using MCM template mcm-templates/replication-cluster
#    mcm < mcm-templates/replication-cluster
# 2) Run this script
#
# MySQL Cluster-1              MySQL Cluster-2
#   MySQL-53316   ----------->   MySQL-53326 (slave)
#

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

#
# Configure replication MySQL-53316 -> MySQL-53326 (slave)
#
echo "Configure replication: MySQL-53316 -> MySQL-53326 (slave)"
LOGFILE=`mysql -uroot -h127.0.0.1 -P53316 -e "show master status\G"|grep File|cut -f2 -d:|sed  "s/ //g"`
LOGPOS=`mysql -uroot -h127.0.0.1 -P53316 -e "show master status\G"|grep Position|cut -f2 -d:|sed  "s/ //g"`
echo "LOGFILE=$LOGFILE,LOGPOS=$LOGPOS"

mysql -uroot -h127.0.0.1 -P53326 << EOL
change master to
	master_host='127.0.0.1',
	master_port=53316,
	master_user='rep',
	master_password='rep',
  get_master_public_key=1,
	master_log_file="$LOGFILE",
	master_log_pos=$LOGPOS;
EOL

# Add grants needed for replication on masters (Cluster-1)
mysql -uroot -h127.0.0.1 -P53316 << EOL
SET sql_log_bin=0;
create user rep@'%' identified by 'rep';
grant replication slave on *.* to rep@'%';
SET sql_log_bin=1;
EOL

mysql -uroot -h127.0.0.1 -P53317 << EOL
SET sql_log_bin=0;
create user rep@'%' identified by 'rep';
grant replication slave on *.* to rep@'%';
SET sql_log_bin=1;
EOL

mysql -uroot -h127.0.0.1 -P53326 -e "show slave status\G"
echo "press <ENTER> to start replication"
read
# start replication
#
mysql -uroot -h127.0.0.1 -P53326 -e "start slave"
mysql -uroot -h127.0.0.1 -P53326 -e "show slave status\G"

#!/bin/bash
#
#   MySQL Site-1               MySQL Site-2
# ==========================================
#   MySQL-53316 -------------> MySQL-53326 (slave)
#   MySQL-53317                MySQL-53327
#   to
#   MySQL-53316                MySQL-53326
#   MySQL-53317 -------------> MySQL-53327 (slave)
#
# Demo script to move replication chanel as shown above
#

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

echo "Starting channel cut-over from (MySQL-53316 ---X---> MySQL-53326) to (MySQL-53317 -----> MySQL-53327 (slave))"
echo "press <ENTER> to continue"
read

# Break/Stop replication between MySQL-53316 ---X---> MySQL-53326
echo "Breaking replication between 53316 -> 53326"
mysql -uroot -h127.0.0.1 -P53326 -e "stop slave"
mysql -uroot -h127.0.0.1 -P53326 -e "show slave status\G"
echo "press <ENTER> to continue"
read

# Configure replication MySQL-53317 -----> MySQL-53327 (slave)

epoch=`mysql -uroot -h127.0.0.1 -P53327 -se"SELECT MAX(epoch) FROM mysql.ndb_apply_status\G" |grep epoch| cut -f2 -d:|sed  "s/ //g"`
[ -z $epoch ] && echo "epoch empty, exiting.." && exit 1

#LOGFILE=`mysql -uroot -h127.0.0.1 -P53317 -se"SELECT SUBSTRING_INDEX(next_file, '/', -1), next_position FROM mysql.ndb_binlog_index WHERE epoch >= $epoch ORDER BY epoch ASC LIMIT 1\G" |grep next_file|cut -f2 -d:|sed  "s/ //g"`
#LOGPOS=`mysql -uroot -h127.0.0.1 -P53317 -se"SELECT SUBSTRING_INDEX(next_file, '/', -1), next_position FROM mysql.ndb_binlog_index WHERE epoch >= $epoch ORDER BY epoch ASC LIMIT 1\G" |grep next_position|cut -f2 -d:|sed  "s/ //g"`
LOGFILE=`mysql -uroot -h127.0.0.1 -P53317 -se"SELECT SUBSTRING_INDEX(next_file, '/', -1), next_position FROM mysql.ndb_binlog_index WHERE epoch = $epoch\G" |grep next_file|cut -f2 -d:|sed  "s/ //g"`
LOGPOS=`mysql -uroot -h127.0.0.1 -P53317 -se"SELECT SUBSTRING_INDEX(next_file, '/', -1), next_position FROM mysql.ndb_binlog_index WHERE epoch = $epoch\G" |grep next_position|cut -f2 -d:|sed  "s/ //g"`

echo "Epoch from 53327 = ($epoch), LOGFILE and LOGPOS fetched from 53317; LOGFILE=($LOGFILE) LOGPOS=($LOGPOS)"
echo "press <ENTER> to continue"
read

[ -z $LOGFILE ] && echo "LOGFILE empty, exiting.." && exit 1
[ -z $LOGPOS ] && echo "LOGPOS empty, exiting.." && exit 1

mysql -uroot -h127.0.0.1 -P53327 << EOL

change master to
	master_host='127.0.0.1',
	master_port=53317,
	master_user='rep',
	master_password='rep',
	master_log_file="$LOGFILE",
	master_log_pos=$LOGPOS,
 	get_master_public_key=1;
EOL

# start replication
mysql -uroot -h127.0.0.1 -P53327 -e "start slave"
mysql -uroot -h127.0.0.1 -P53327 -e "show slave status\G"


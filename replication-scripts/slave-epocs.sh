
mysql -uroot -P53326 -h127.0.0.1 -e"select @@port,server_id,epoch,log_name,start_pos,end_pos from mysql.ndb_apply_status"
mysql -uroot -P53327 -h127.0.0.1 -e"select @@port,server_id,epoch,log_name,start_pos,end_pos from mysql.ndb_apply_status"

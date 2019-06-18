-- watch "mysql -uroot -proot -P3310 -h127.0.0.1 < tools/counter-stats.sql"

create database IF NOT EXISTS stats;
use stats;
drop table IF EXISTS c1, c2;
create table c1 (select * from ndbinfo.counters);
select sleep(1);
create table c2 (select * from ndbinfo.counters);
select c2.node_id,
       c2.block_name as bl_name,
       c2.block_instance as bl_inst,
       c2.counter_name as block_name,
       c2.val - c1.val as value
from stats.c1, stats.c2
where 
  c1.node_id = c2.node_id
  and c1.block_name = c2.block_name
  and c1.block_instance = c2.block_instance
  and c1.counter_id = c2.counter_id
  and (c2.val-c1.val) != 0;
drop database stats;

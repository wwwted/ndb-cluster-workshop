#!/bin/bash

mysql -uroot -h127.0.0.1 -P3310 << EOC
create database if not exists test;
drop table if exists test.t1;
create table test.t1 (f1 int not null auto_increment primary key, f2 varchar(20)) engine=ndbcluster;
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
insert into test.t1 (f2) values ("hello");
select * from test.t1;

EOC
echo "Press <ENTER> to continue"
read

/home/ted/demos/mcm/cluster-758/bin/ndb_desc -c127.0.0.1:1186 -dtest -p t1


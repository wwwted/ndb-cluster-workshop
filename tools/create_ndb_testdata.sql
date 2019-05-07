drop database IF EXISTS ted;
create database ted;
use ted;

create table test (
   id int primary key auto_increment,
   name varchar(32),
   address varchar(32),
   age int,
   index (name)
)engine=ndb ;


DELIMITER $$
CREATE PROCEDURE prepare_data()
BEGIN
  DECLARE i INT DEFAULT 100;
  WHILE i < 10000 DO
    INSERT INTO ted.test (id,name,address,age) VALUES (i,CONCAT("ted",i),CONCAT("address",i),i);
    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

CALL prepare_data();

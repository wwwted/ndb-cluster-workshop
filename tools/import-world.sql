
create database world;
use world;

source /home/ted/ws/world.sql

alter table city drop foreign key city_ibfk_1;
alter table countrylanguage drop foreign key countryLanguage_ibfk_1;

alter table countrylanguage engine=ndbcluster;
alter table city engine=ndbcluster;
alter table country engine=ndbcluster;


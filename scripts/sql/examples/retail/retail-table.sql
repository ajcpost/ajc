create database retail;
use retail;

## Manufacturer
create table manufacturer (id int not null primary key, name varchar (50) not null);
insert into manufacturer  values (1, 'motorola');
insert into manufacturer  values (2, 'htc');
insert into manufacturer  values (3, 'samsung');
insert into manufacturer  values (4, 'sony');
insert into manufacturer  values (5, 'apple');
insert into manufacturer  values (6, 'lg');
insert into manufacturer  values (7, 'nokia');
insert into manufacturer  values (8, 'acer');
insert into manufacturer  values (9, 'hp');

## Product categoties
create table category (id int not null primary key, category varchar (50) not null);
insert into category values (1, 'smartphone');
insert into category values (2, 'tablet');
insert into category values (3, 'laptop');


## Product list
create table product (id int not null primary key, name varchar (50) not null, price int not null, category int not null references category(id), manufacturer int not null references manufacturer (id));
insert into product values (1, 'moto-razor',50,1,1);
insert into product values (2, 'moto-defy',70,1,1);
insert into product values (3, 'moto-droid',40,1,1);
insert into product values (4, 'htc-sp1',75,1,2);
insert into product values (5, 'htc-sp2',95,1,2);
insert into product values (6, 'htc-sp3',45,1,2);
insert into product values (7, 'samsung-sp1',58,1,3);
insert into product values (8, 'samsung-sp2',73,1,3);
insert into product values (9, 'sony-sp1',70,1,4);
insert into product values (10, 'apple-sp1',100,1,5);
insert into product values (11, 'apple-laptop1',200,3,5);
insert into product values (12, 'lg-sp1',65,1,6);
insert into product values (13, 'lg-sp2',80,1,6);
insert into product values (14, 'nokia-sp1',78,1,7);
insert into product values (15, 'nokia-sp1',80,1,7);
insert into product values (16, 'nokia-sp1',90,1,7);
insert into product values (17, 'acer-tablet1',100,2,8);
insert into product values (18, 'acer-tablet2',120,2,8);
insert into product values (19, 'acer-laptop1',150,3,8);
insert into product values (20, 'hp-laptop1',80,3,9);
insert into product values (21, 'hp-laptop2',140,3,9);
insert into product values (22, 'hp-tablet1',74,2,9);
insert into product values (23, 'hp-tablet2',85,2,9);

## Customers
create table customer (id int not null primary key, login varchar (50) not null unique key, name varchar (50) not null);
insert into customer values (1, 'aj', 'ajay');
insert into customer values (2, 'john', 'john');
insert into customer values (3, 'mike', 'mike');
insert into customer values (4, 'xyz', 'xyz');
insert into customer values (5, 'chris', 'chris');

## Sales
create table sales (id int not null primary key, product int not null references product (id), quantity int not null, login varchar (50) not null references customer (login), time timestamp not null);
insert into sales values (1, 2, 1, 'aj', '2013-07-01 10:00:00');
insert into sales values (2, 2, 1, 'invalid', '2011-01-01 10:00:00');
insert into sales values (3, 19, 1, 'aj', '2013-08-01 10:00:00');
insert into sales values (4, 17, 1, 'aj', '2013-09-01 10:00:00');
insert into sales values (5, 1, 2, 'john', '2013-01-01 10:00:00');
insert into sales values (6, 23, 1, 'john', '2013-10-01 10:00:00');
insert into sales values (7, 3, 3, 'mike', '2012-07-01 10:00:00');
insert into sales values (8, 5, 1, 'mike', '2013-05-01 10:00:00');
insert into sales values (9, 13, 2, 'mike', '2012-04-01 10:00:00');
insert into sales values (10, 7, 1, 'mike', '2013-07-01 10:00:00');
insert into sales values (11, 12, 1, 'mike', '2013-10-01 10:00:00');
insert into sales values (12, 5, 1, 'mike', '2013-11-01 10:00:00');
insert into sales values (13, 11, 10, 'xyz', '2013-04-01 10:00:00');
insert into sales values (14, 21, 5, 'xyz', '2013-09-01 10:00:00');
insert into sales values (15, 2, 1, 'xyz', '2012-05-01 10:00:00');
insert into sales values (16, 2, 1, 'john', '2013-06-01 10:00:00');
insert into sales values (17, 10, 1, 'john', '2013-06-01 10:00:00');
insert into sales values (18, 9, 1, 'aj', '2013-12-01 10:00:00');

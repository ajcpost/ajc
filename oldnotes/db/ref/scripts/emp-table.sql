create database emp;
use emp;

## Employee
create table employee (id int not null primary key, name varchar (20) not null, manager int references employee(id), sal int);
insert into employee  values (1, 'john', null, 10000);
insert into employee  values (2, 'mike', 1, 800);
insert into employee  values (3, 'chris', 1, 750);
insert into employee  values (4, 'clay', 3, 500);
insert into employee  values (5, 'mark', 3, 520);
insert into employee  values (6, 'pat', 2, 600);


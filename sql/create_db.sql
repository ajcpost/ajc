
create database if not exists pf;

------------------Account---------------------------------
create table if not exists pf.account (
    id integer auto_increment unique,
    name varchar(50) not null unique,
    foreign key (status) references pf.account_status (status) on delete cascade
    index idx_id (id),
    index idx_name (name)
) engine = innodb;

create table if not exists pf.account_status (
    status integer not null unique
) engine = innodb;

------------------User---------------------------------    
create table if not exists pf.user (
    id integer auto_increment unique,
    login varchar(20) not null unique,
    password varchar(8) not null,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    ctime datetime not null,
    foreign key (role) references pf.user_role (role) on delete cascade
    foreign key (status) references pf.user_status (status) on delete cascade
    index idx_id (id),
    index idx_login (login)
) engine = innodb;

create table if not exists pf.user_role (
    role integer not null unique
) engine = innodb;

create table if not exists pf.user_status (
    status integer
) engine = innodb;

    
create table if not exists pf.exchange (
    exchange varchar(50) not null unique,
    name varchar(50) not null,
    index idx_exchange (exchange)
) engine = innodb;

create table if not exists pf.symbol (
    symbol varchar(50) not null unique,
    name varchar(50),
    exchange varchar(50) not null,
    index idx_symbol (symbol),
    foreign key (exchange) references pf.exchange (exchange) on delete cascade
) engine = innodb;

create table if not exists pf.folio (
    login varchar(20) not null,   
    symbol varchar(50) not null,
    primary key (login, symbol),
    foreign key (login) references pf.user (login) on delete cascade,
    foreign key (symbol) references pf.symbol (symbol) on delete cascade
) engine = innodb;

create table if not exists pf.buy (
    login varchar (20) not null,
    symbol varchar(50) not null,
    quantity integer unsigned not null,
    price double unsigned not null,
    tax double unsigned not null,
    time datetime not null,    
    primary key (login, symbol),
    foreign key (login) references pf.user (login) on delete cascade,
    foreign key (symbol) references pf.symbol (symbol) on delete cascade
) engine = innodb;

create table if not exists pf.sell (
    login varchar (20) not null,
    symbol varchar(50) not null,
    quantity integer unsigned not null,
    price double unsigned not null,
    tax double unsigned not null,
    time datetime not null,    
    primary key (login, symbol),
    foreign key (login) references pf.user (login) on delete cascade,
    foreign key (symbol) references pf.symbol (symbol) on delete cascade
) engine = innodb;

create table if not exists pf.dividend (
    login varchar (20) not null,
    symbol varchar(50) not null,
    amount double unsigned not null,
    time datetime not null,    
    primary key (login, symbol),
    foreign key (login) references pf.user (login) on delete cascade,
    foreign key (symbol) references pf.symbol (symbol) on delete cascade
) engine = innodb;
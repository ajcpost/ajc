##########################################
### Schema
### - For autoincrement columns, use DEFAULT keyword
### - No need to separately create index for primary and unique columns
### - insert into article values (11, 0, 1, 3, 'published-revoked', 'Ariba test article, published and then revoked', now(), now(), 'store/2000/06/');
### - insert into article values (DEFAULT, 5, 'Test: Java article, submitted', '', 'store/2000/05/', '2000-05-05 18:19:03', '2000-05-05 18:19:03', -1, 0);
### - insert into article values (1, 0, 1, 1, 'authored & approved', 'Unknwon test article, approved but not published', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'store/2000/06/');
##########################################


create database daby;
use daby;

### User
### <user_state> 
### * 0: active user
### * -1: internal user
### * -2: test user
### * -99: banned user
create table `user` (
    id int unsigned not null auto_increment,
    username varchar (30) not null,
    password text not null,
    user_state int not null, 
    email varchar (50) not null,
    email_visible int,
    firstname varchar (30),
    lastname varchar (30),
    about_me text,
    created timestamp not null default current_timestamp, 
    updated timestamp not null default current_timestamp on update current_timestamp, 
    primary key (id)
);
insert into user values (DEFAULT, 'admin', ' ', -1, 'admin@', 1, '', '', 'admin user', '', '');
insert into user values (DEFAULT, 'approver', ' ', -1, 'approver@', 1, '', '', 'approver', '', '');


### Role
### <role> 
### * admin:  superuser, can browse/submit/comment and approve article
### * member: can browse/submit/comment
### * guest:  can browse
create table role (
    id int unsigned not null auto_increment,
    role varchar (30) not null,
    primary key (id)
);

insert into role values (DEFAULT, 'admin');
insert into role values (DEFAULT, 'approver');

### User-Role
create table user_role (
    userid int unsigned not null,
    roleid int unsigned not null,
    foreign key (userid) references `user`(id) on delete cascade on update cascade,
    foreign key (roleid) references `role`(id) on delete cascade on update cascade,
    primary key (userid, roleid)
);

insert into user_role values (1, 1);
insert into user_role values (1, 2);
insert into user_role values (2, 2);


### Article
### <article_type> 
### * 0: normal
### * -1: test
### <article_state> 
### * 0: submitted 
### * 1: published
### * -1: revoked
create table article (
    id int unsigned not null auto_increment,
    userid int unsigned not null,
    title varchar(100) not null, 
    content_summary varchar (200),
    content_location varchar (1000) not null,
    created timestamp not null default current_timestamp,
    updated timestamp not null default current_timestamp on update current_timestamp, 
    article_type int not null, 
    article_state int not null, 
    foreign key (userid) references `user`(id) on delete cascade on update cascade,
    primary key (id)
);
create index index_state on article (article_state);
create index index_updated on article (updated);

### Comment
### <comment_state>
### * 0: published 
### * -1: revoked
create table comment (
    id int unsigned not null auto_increment,
    articleid int unsigned not null,
    userid int unsigned not null,
    content text not null,
    created timestamp not null default current_timestamp, 
    comment_state int not null, 
    foreign key (articleid) references `article`(id) on delete cascade on update cascade,
    foreign key (userid) references `user`(id) on delete cascade on update cascade,
    primary key (id)
);
create index index_articleid on comment (articleid);


### Tag
create table tag (
    id int unsigned not null auto_increment,
    tag varchar (30) not null,
    description varchar (200) not null,
    primary key (id)
);

insert into tag values (DEFAULT, 'unknown', '');
insert into tag values (DEFAULT, 'java', '');
insert into tag values (DEFAULT, 'kerberos', '');
insert into tag values (DEFAULT, 'ssl', '');
insert into tag values (DEFAULT, 'encryption', '');
insert into tag values (DEFAULT, 'perl', '');
insert into tag values (DEFAULT, 'ariba', '');
insert into tag values (DEFAULT, 'multicast', '');
insert into tag values (DEFAULT, 'sql', '');
insert into tag values (DEFAULT, 'puzzle', '');

### Article-Tag
create table article_tag (
    articleid int unsigned not null,
    tagid int unsigned not null,
    foreign key (articleid) references `article`(id) on delete cascade on update cascade,
    foreign key (tagid) references `tag`(id) on delete cascade on update cascade,
    primary key (articleid, tagid)
);

##########################################

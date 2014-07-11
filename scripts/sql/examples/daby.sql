##########################################
### Schema
### - For autoincrement columns, use DEFAULT keyword
### - No need to separately create index for primary and unique columns
### - insert into article values (11, 0, 1, 3, 'published-revoked', 'Ariba test article, published and then revoked', now(), now(), 'store/2014/06/');
### - insert into article values (1, 0, 1, 1, 'authored & approved', 'Unknwon test article, approved but not published', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'store/2014/06/');
##########################################


create database daby;
use daby;

### User
### <user_state> 
### * 0: active user
### * -1: internal user
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
    primary key (id)
);
insert into user values (DEFAULT, 'admin', ' ', -1, 'admin@', 1, '', '', 'admin user');
insert into user values (DEFAULT, 'approver', ' ', -1, 'approver@', 1, '', '', 'approver');
insert into user values (DEFAULT, 'user-A', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-B', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-C', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-D', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-E', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-F', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-G', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-H', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-I', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'user-J', ' ', 0, 'test@', 1, '', '', 'test user');
insert into user values (DEFAULT, 'banned', ' ', -99, 'test@', 1, '', '', 'banned user');


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
insert into role values (DEFAULT, 'member');


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
### * -1: test (not visible except for admin role)
### <article_state> 
### * 0: submitted 
### * 1: published
### * -1: revoked
create table article (
    id int unsigned not null auto_increment,
    userid int unsigned not null,
    title varchar(50) not null, 
    description varchar(100) not null, 
    #content_location varchar (1000) not null,
    content TEXT,
    created timestamp not null, 
    updated timestamp not null, 
    article_type int not null, 
    article_state int not null, 
    foreign key (userid) references `user`(id) on delete cascade on update cascade,
    primary key (id)
);
create index index_state on article (article_state);
create index index_updated on article (updated);

insert into article values (DEFAULT, 5, 'submitted', 'Java test article, submitted but not published', 'store/2014/05/', '2014-05-05 18:19:03', '2014-05-05 18:19:03', -1, 0);
insert into article values (DEFAULT, 3, 'submitted', 'Unknwon test article, submitted but not published', 'store/2014/05/', '2014-05-05 18:19:03', '2014-05-05 18:19:03', -1, 0);
insert into article values (DEFAULT, 5, 'published', 'Java/Unknwon test article-2', 'store/2014/05/', '2014-05-05 18:19:03', '2014-05-05 18:19:03', -1, 1);
insert into article values (DEFAULT, 4, 'published', 'Scripting test article-3', 'store/2014/06/', '2014-06-06 18:19:03', '2014-06-06 18:19:03', -1, 1);
insert into article values (DEFAULT, 6, 'published', 'Java/Unknwon test article-4', 'store/2014/06/', '2014-06-06 18:19:03', '2014-06-06 18:19:03', -1, 1);
insert into article values (DEFAULT, 6, 'published', 'Ariba/Java test article-5', 'store/2014/06/', '2014-06-06 18:19:03', '2014-06-06 18:19:03', -1, 1);
insert into article values (DEFAULT, 8, 'published', 'Scripting article-6', 'store/2014/06/', '2014-06-06 18:19:03', '2014-06-06 18:19:03', -1, 1);
insert into article values (DEFAULT, 5, 'published', 'Perl/Scripting article-7', 'store/2014/06/', '2014-06-06 18:19:03', '2014-06-06 18:19:03', -1, 1);
insert into article values (DEFAULT, 3, 'published', 'Ariba article-8', 'store/2014/07/', '2014-07-07 18:19:03', '2014-07-07 18:19:03', -1, 1);
insert into article values (DEFAULT, 6, 'published', 'Ariba/Java article-9', 'store/2014/07/', '2014-07-07 18:19:03', '2014-07-07 18:19:03', -1, 1);
insert into article values (DEFAULT, 3, 'published', 'Networking article-10', 'store/2014/07/', '2014-07-07 18:19:03', '2014-07-07 18:19:03', -1, 1);
insert into article values (DEFAULT, 9, 'published-revoked', 'Ariba test article, published and then revoked', 'store/2014/07/', '2014-07-07 18:19:03', '2014-07-07 18:19:03', -1, -1);


### Comment
### <comment_state>
### * 0: published 
### * -1: revoked
create table comment (
    id int unsigned not null auto_increment,
    articleid int unsigned not null,
    userid int unsigned not null,
    #content_location varchar (1000) not null,
    content text,
    created timestamp not null, 
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

insert into tag values (DEFAULT, 'java', '');
insert into tag values (DEFAULT, 'scripting', '');
insert into tag values (DEFAULT, 'networking', '');
insert into tag values (DEFAULT, 'perl', '');
insert into tag values (DEFAULT, 'ariba', '');
insert into tag values (DEFAULT, 'unknown', '');

### Article-Tag
create table article_tag (
    articleid int unsigned not null,
    tagid int unsigned not null,
    foreign key (articleid) references `article`(id) on delete cascade on update cascade,
    foreign key (tagid) references `tag`(id) on delete cascade on update cascade,
    primary key (articleid, tagid)
);


insert into article_tag values (1, 1);
insert into article_tag values (2, 6);
insert into article_tag values (3, 1);
insert into article_tag values (3, 6);
insert into article_tag values (4, 2);
insert into article_tag values (5, 1);
insert into article_tag values (5, 6);
insert into article_tag values (6, 5);
insert into article_tag values (6, 1);
insert into article_tag values (7, 2);
insert into article_tag values (8, 4);
insert into article_tag values (8, 2);
insert into article_tag values (9, 5);
insert into article_tag values (10, 5);
insert into article_tag values (10, 1);
insert into article_tag values (11, 3);
insert into article_tag values (12, 5);

##########################################

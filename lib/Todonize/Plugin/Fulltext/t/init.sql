drop table if exists todo_test;

CREATE TABLE todo_test (
  id integer primary key auto_increment,
  title TEXT, FULLTEXT(title) WITH PARSER mecab
) ENGINE=myisam DEFAULT CHARSET=utf8;

insert into todo_test (title) values ("釣り"), ("aとデート"), ("bとデート"), ("cとデート"), ("デートプラン立てる"), ("池袋のデートプラン立てる");

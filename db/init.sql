drop table if exists todos;

create table if not exists todos (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  content TEXT not null,
  last_update DATETIME not null
) DEFAULT CHARSET=utf8;

create index last_update_idx on todos (last_update);

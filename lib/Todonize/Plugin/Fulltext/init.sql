alter table todo engine=myisam;

alter table todo
add fulltext(title) with parser mecab;

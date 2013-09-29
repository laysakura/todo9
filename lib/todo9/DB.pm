package todo9::DB;

use strict;
use warnings;
use utf8;
use DBI;
use Data::Dumper;
use todo9::Config;

sub _get_dbh {
    my $dbh = DBI->connect(
        sprintf("dbi:mysql:%s:%s", config->param('db'), config->param('host')),
        config->param('user'),
        config->param('pass'),
        { mysql_enable_utf8 => 1 }
    ) or die 'connection failed';
    return $dbh
};

sub _add {
    my $content = shift;
    my $dbh = _get_dbh();
    my $table = config->param('table');

    my $sth = $dbh->prepare("insert into $table (content, last_update) values (?, now());");
    $sth->execute($content) or die 'cannot replace the row';
    $sth->finish;

    $dbh->disconnect;
};

sub add_todo {
    my $content = shift;
    _add($content);
};

# @param  id of row to fetch
# @param  content
# @returns  [id, todo, datetime], undef if not found
sub edit_todo_by_id {
    my $id = shift;
    my $content = shift;
    my $dbh = _get_dbh();
    my $table = config->param('table');

    my $sth = $dbh->prepare("update $table set content=? where id=$id");
    $sth->execute($content);
};

# @param  id of row to delete
# @returns  [id, todo, datetime], undef if not found
sub delete_todo_by_id {
    my $id = shift;
    my $dbh = _get_dbh();
    my $table = config->param('table');

    my $sth = $dbh->prepare("delete from $table where id=$id");
    $sth->execute();
};

# @param  SQL query
# @returns  [ [col, col, ...], [...], ... ]
sub select {
    my $query = shift;
    my $dbh = _get_dbh();
    $dbh->selectall_arrayref($query);
};

1;

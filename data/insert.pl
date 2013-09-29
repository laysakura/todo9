#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;

my $db = 'test';
my $host = 'localhost';
my $user = 'root';
my $pass = '';
my $table = 'todos_large';

sub _get_dbh {
    my $dbh = DBI->connect(
        sprintf("dbi:mysql:%s:%s", $db, $host),
        $user,
        $pass,
        { mysql_enable_utf8 => 1 }
    ) or die 'connection failed';
    return $dbh
};


while (my $line = <STDIN>) {
    chomp $line;

    # FIXME: 何故かUTF8でinsertできない・・・
    my $dbh = _get_dbh();
    my $sth = $dbh->prepare("insert into $table (content, last_update) values (?, now());");
    $sth->execute($line) or die 'cannot replace the row';;

    # `mysql -u $user $db -e "insert into $table (content, last_update) values ('$line', now());"`
}

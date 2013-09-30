package Todonize::Plugin::Fulltext::DB;

use strict;
use warnings;
use utf8;
use DBI;

# @param  dbh
# @param  DML SQL
# @param  ['placeholder1', 'placeholder2', ... ]
sub dml {
    my ($dbh, $dml, $placeholders) = @_;
    my $sth = $dbh->prepare($dml);
    $sth->execute(@$placeholders);
}

# @param  dbh
# @param  SQL query
# @returns  [ [col, col, ...], [...], ... ]
sub select {
    my ($dbh, $query) = @_;
    $dbh->selectall_arrayref($query ,{Columns=>{}});
};

1;

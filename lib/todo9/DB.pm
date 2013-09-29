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

# @param  DML SQL
# @param  ['placeholder1', 'placeholder2', ... ]
sub dml {
    my ($dml, $placeholders) = @_;
    my $dbh = _get_dbh();
    my $sth = $dbh->prepare($dml);
    $sth->execute(@$placeholders);
}

# @param  SQL query
# @returns  [ [col, col, ...], [...], ... ]
sub select {
    my $query = shift;
    my $dbh = _get_dbh();
    $dbh->selectall_arrayref($query);
};

1;

package Todonize::Plugin::Fulltext::API;

use strict;
use warnings;
use utf8;
use Todonize::Plugin::Fulltext::DB;

# @param dbh
# @param query  e.g. "デート" (utf-8)
# @param rec_offset
# @param rec_num  [rec_offset, rec_offset + rec_num] records are returned.
# @returns  List like below:
#    [
#        { "id": 122, "title": "あゆみとデート", ...},
#        { "id": 138, "title": "いぶとデート", ...},
#        { "id": 157, "title": "池袋デートスポット調べる", ...},
#    ]
# @example
#   my $offset = 1;
#   my $n = 2;
#   my $res3 = Todonize::Plugin::Fulltext::API::_search($dbh, 'todo_test', 'デート', $offset, $n);
#   while (@{$res3} != 0) {
#       print Dumper $res3;
#       $offset += $n;
#       $res3 = Todonize::Plugin::Fulltext::API::_search($dbh, 'todo_test', 'デート', $offset, $n);
#   }
sub search {
    my ($dbh, $query, $rec_offset, $rec_num) = @_;
    _search($dbh, 'todo', $query, $rec_offset, $rec_num);
}

# ONLY FOR TESTING
sub _search {
    my ($dbh, $table, $query, $rec_offset, $rec_num) = @_;
    my $sql = "select * from $table where match(title) against('+\"$query\"' in boolean mode) limit $rec_offset, $rec_num";
    Todonize::Plugin::Fulltext::DB::select($dbh, $sql);
}

1;

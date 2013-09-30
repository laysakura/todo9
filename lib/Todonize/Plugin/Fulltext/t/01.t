#! /usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;
use Todonize::Plugin::Fulltext::API;
use Data::Dumper;

use Test::More tests => 5;

my $db = $ENV{DB_DB} || "test";
my $host = $ENV{DB_HOST} || "localhost";
my $user = $ENV{DB_USER} || "root";
my $pass = $ENV{DB_PASS} || "";
my $dbh = DBI->connect(
    $ENV{DBI} || "dbi:mysql:$db:$host",
    $user, $pass,
    { mysql_enable_utf8 => 1 }
) or die 'connection failed:';

my $res1 = Todonize::Plugin::Fulltext::API::_search($dbh, 'todo_test', 'デート', 2, 3);
ok(scalar(@{$res1}) == 3);
is_deeply(
    $res1->[0],
    { 'id' => '4', 'title' => "cとデート" });
is_deeply(
    $res1->[1],
    { 'id' => '5', 'title' => "デートプラン立てる" });
is_deeply(
    $res1->[2],
    { 'id' => '6', 'title' => "池袋のデートプラン立てる" });

my $res2 = Todonize::Plugin::Fulltext::API::_search($dbh, 'todo_test', 'デート', 1, 100);
ok(scalar(@{$res2}) == 4);

package todo9::Config;

use strict;
use warnings;
use Config::ENV 'PLACK_ENV', export => 'config';

config development => +{
    db => $ENV{DB_DB} || "test",
    host => $ENV{DB_HOST} || "localhost",  # 0.0.0.0:3306
    user => $ENV{DB_USER} || "root",
    pass => $ENV{DB_PASS} || "",
    table => $ENV{DB_TABLE} || "memo",
};

config production => +{
    db => $ENV{DB_DB} || "test",
    host => $ENV{DB_HOST} || "localhost",  # 0.0.0.0:3306
    user => $ENV{DB_USER} || "root",
    pass => $ENV{DB_PASS} || "",
    table => $ENV{DB_TABLE} || "memo",
};

1;

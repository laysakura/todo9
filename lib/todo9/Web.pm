package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Todonize::Plugin::Fulltext::DB;
use Data::Dumper;
use todo9::Config;

my $table = config->param('table');
my $dbh = DBI->connect(
    $ENV{DBI} || "dbi:mysql:" . config->param('db') . ":" . config->param('host'),
    config->param('user'), config->param('pass'),
    { mysql_enable_utf8 => 1 }
) or die 'connection failed:';


get '/' => sub {
    my ( $self, $c )  = @_;

    my $todos = Todonize::Plugin::Fulltext::DB::select($dbh, "select * from $table limit 10");
    $c->render('index.tx',
               {
                   todos => $todos,
               });
};

post '/' => sub {
    my ( $self, $c ) = @_;

    my $form = $c->req->validator([
        'todo' => {
            'rule' => [],
        }]);
    eval {
        Todonize::Plugin::Fulltext::DB::dml($dbh, "insert into $table (content, last_update) values (?, now())", [$form->valid('todo')]);
        $c->redirect('/');
    };
    if ($@) {
        print $@;
        $c->res->status(500);
    }
    return $c->res;
};

get '/todos/:id' => sub {
    my ( $self, $c ) = @_;

    my $id = $c->args->{id};
    my $todos = Todonize::Plugin::Fulltext::DB::select($dbh, "select * from $table where id=$id limit 1");
    $c->render('edit.tx',
               {
                   id => $id,
                   content => $todos->[0]{content},
                   last_update => $todos->[0]{last_update},
               });
};

post '/todos/:id' => sub {
    my ( $self, $c ) = @_;

    my $id = $c->args->{id};

    my $form = $c->req->validator([
        'todo' => {
            'rule' => [],
        }]);

    my $content = $form->valid('todo');
    Todonize::Plugin::Fulltext::DB::dml($dbh, "update $table set content=? where id=$id", [$content]);
    $c->redirect('/');
};

# delete
post '/todos/:id/delete' => sub {
    my ( $self, $c ) = @_;

    my $id = $c->args->{id};
    Todonize::Plugin::Fulltext::DB::dml($dbh, "delete from $table where id=$id", []);
    $c->redirect('/');
};

get '/search_result' => sub {
    my ( $self, $c )  = @_;

    my $opt = $c->req->validator([
        'q' => {
            rule => [],
        }]);
    my $query = $opt->valid->get('q');

    my $todos = Todonize::Plugin::Fulltext::DB::select($dbh, "select * from $table where match(content) against('+\"$query\"' in boolean mode) limit 20");
    $c->render('search_result.tx',
               {
                   query => $query,
                   len_results => scalar(@{$todos}),
                   todos => $todos,
               });
};

1;

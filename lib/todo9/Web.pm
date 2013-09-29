package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use todo9::DB;
use Data::Dumper;
use todo9::Config;

my $table = config->param('table');

get '/' => sub {
    my ( $self, $c )  = @_;

    my $todos = todo9::DB::select("select * from $table limit 10");
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
        todo9::DB::add_todo($form->valid('todo'));
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
    my $todos = todo9::DB::select("select * from $table where id=$id limit 1");
    $c->render('edit.tx',
               {
                   id => $id,
                   content => $todos->[0][1],
                   last_update => $todos->[0][2],
               });
};

post '/todos/:id' => sub {
    my ( $self, $c ) = @_;

    my $id = $c->args->{id};

    my $form = $c->req->validator([
        'todo' => {
            'rule' => [],
        }]);

    # FIXME: 例外使おう
    my $content = $form->valid('todo');
    todo9::DB::edit_todo_by_id($id, $content);
    $c->redirect('/');
};

# delete
post '/todos/:id/delete' => sub {
    my ( $self, $c ) = @_;

    my $id = $c->args->{id};
    todo9::DB::delete_todo_by_id($id);
    $c->redirect('/');
};

get '/search_result' => sub {
    my ( $self, $c )  = @_;

    my $opt = $c->req->validator([
        'q' => {
            rule => [],
        }]);
    my $query = $opt->valid->get('q');

    my $todos = todo9::DB::select("select * from $table where match(content) against('+\"$query\"' in boolean mode) limit 20");
    $c->render('search_result.tx',
               {
                   query => $query,
                   len_results => scalar(@{$todos}),
                   todos => $todos,
               });
};

1;

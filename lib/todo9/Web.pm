package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use todo9::DB;
use Data::Dumper;
use todo9::Config;


get '/' => sub {
    my ( $self, $c )  = @_;

    my $todos = todo9::DB::read_todos(10) or die 'DB select error';
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
    my @todo = todo9::DB::fetch_todo_by_id($id) or die 'DB select error';
    $c->render('edit.tx',
               {
                   id => $id,
                   content => $todo[1],
                   last_update => $todo[2],
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

1;


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
    # die Dumper @todo;
    $c->render('edit.tx',
               {
                   content => $todo[1],
                   last_update => $todo[2],
               });
};

1;


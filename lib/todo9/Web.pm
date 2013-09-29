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

1;


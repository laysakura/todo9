package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use todo9::DB;
use todo9::Config;


get '/' => sub {
    my ( $self, $c )  = @_;

    my $db = todo9::DB::read_memo();
    $c->render('index.tx',
               {
                   memo_content => $db->{content},
                   last_update => $db->{last_update},
               });
};

post '/' => sub {
    my ( $self, $c ) = @_;

    my $form = $c->req->validator([
        'memo-area' => {
            'rule' => [],
        }]);
    eval {
        todo9::DB::save_memo($form->valid('memo-area'));
        $c->redirect('/');
    };
    if ($@) {
        print $@;
        $c->res->status(500);
    }
    return $c->res;
};

1;


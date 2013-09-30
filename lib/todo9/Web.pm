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

my $fullscan_sql = "select * from $table";
my $rows;

sub getTable{
	my $tool_tips = "";
	my $return_text = "<table class=\"tablesorter\" id=\"list\" border=\"1\">\n<thead><tr>  <!-- <th style=\"border:solid #000000 1px;width:100px\">重要性</th>  --> <th style=\"border:solid #000000 1px\">内容</th>  <!-- <th style=\"border:solid #000000 1px\">状態</th> -->  <th style=\"border:solid #000000 1px\">最終更新</th><th style=\"border:solid #000000 1px\"></th></tr></thead>";
	foreach my $data (@$rows){
		# my $decode_content = decode('UTF-8', $data->{content});
		my $decode_content = $data->{content};
		my $id = $data->{id};
############################################################################################
        $return_text .=<<EOF;
<tr>
	<!-- <td id="importance_edit$id" style="text-align:center;font-size:15px;vertical-align:middle"><input type="range" value="$data->{importance}" style="width:100px" onMouseUp="editPostSlider('edit', $id, 'importance', this.value)"><div id="importance_num$id" style="display:none">$data->{importance}</div></td> -->
	<td id="content_edit$id" onClick="displayTips($id, 'content')" style="font-size:15px;vertical-align:middle">$decode_content</td>
	<td style="font-size:15px;vertical-align:middle">$data->{last_update}</td>
	<td><input type="button" value="削除" onClick="deletePost('delete', $id)" style="height:30px"></td>
</td></tr>
EOF
############################################################################################
        $tool_tips .=<<EOF;
<div class="tips" id="content_tips$id" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_content_commit$id'>
	<table><tr><td>
	<input name='content' type='textarea' value='$decode_content' onKeyPress='return editEnter(event, $id, "content")'>
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $id, 'content')">
	<input type="button" value="閉じる" onClick="\$('#content_tips$id').hide()">
	</td></tr></table>
  </form>
</div>
<div class="tips" id="importance_tips$id" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_importance_commit$id'>
	<table><tr><td>
	<input name='content' type='textarea' value='$data->{importance}' onKeyPress='return editEnter(event, $id, "importance")' style="width:30px">
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $id, 'importance')">
	<input type="button" value="閉じる" onClick="\$('#importance_tips$id').hide()">
	</td></tr></table>
  </form>
</div>
EOF
############################################################################################
	}
	$return_text .= "</table>";

	$return_text .= $tool_tips;
	return $return_text;
}

get '/' => sub {
    my ( $self, $c )  = @_;

    $rows = Todonize::Plugin::Fulltext::DB::select($dbh, $fullscan_sql);

	$c->render('index.tx', {
		greeting => "Todo9!",
    });
};

get '/table' => sub {
	return getTable($rows);
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

post '/create' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'content' => {
			rule => [
				['NOT_NULL', 'empty body'],
			],
		},
	]);

	if($result->has_error){
		return $c->render_json({error=>1, messages=>$result->errors});
	}

	my $content = $result->valid('content');
    Todonize::Plugin::Fulltext::DB::dml($dbh, "insert into $table (content, last_update) values (?, now())", [$result->valid('content')]);

    $rows = Todonize::Plugin::Fulltext::DB::select($dbh, $fullscan_sql);
	return getTable($rows);
};

post '/delete' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'id' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		}
	]);

	if($result->has_error){
		return $c->render_json({error=>1, messages=>$result->errors});
	}

	my $id = $result->valid('id');
    Todonize::Plugin::Fulltext::DB::dml($dbh, "delete from $table where id=$id", []);

    $rows = Todonize::Plugin::Fulltext::DB::select($dbh, $fullscan_sql);
	return getTable($rows);
};

post '/edit' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'id' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		},
		'content' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		},
		'columnname' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		},
	]);

	if($result->has_error){
		return $c->render_json({error=>1, messages=>$result->errors});
	}

	my $id = $result->valid('id');
	my $content = $result->valid('content');
    Todonize::Plugin::Fulltext::DB::dml($dbh, "update $table set content=?, last_update=now() where id=$id", [$result->valid('content')]);

    $rows = Todonize::Plugin::Fulltext::DB::select($dbh, $fullscan_sql);
	return getTable($rows);
};

get '/search_result' => sub {
    my ( $self, $c )  = @_;

    my $opt = $c->req->validator([
        'q' => {
            rule => [],
        }]);
    my $query = $opt->valid->get('q');

    $rows = Todonize::Plugin::Fulltext::DB::select($dbh, "select * from $table where match(content) against('+\"$query\"' in boolean mode) limit 20");

	$c->render('index.tx', {
		greeting => "Todo9!",
    });
};

1;

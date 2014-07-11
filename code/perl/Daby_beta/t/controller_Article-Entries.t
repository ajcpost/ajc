use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Article::Entries;

ok( request('/article/entries')->is_success, 'Request should succeed' );
done_testing();

use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Article;

ok( request('/article')->is_success, 'Request should succeed' );
done_testing();

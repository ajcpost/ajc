use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Tag;

ok( request('/tag')->is_success, 'Request should succeed' );
done_testing();

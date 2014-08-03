use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Member;

ok( request('/membership')->is_success, 'Request should succeed' );
done_testing();

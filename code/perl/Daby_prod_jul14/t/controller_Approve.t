use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Approve;

ok( request('/approve')->is_success, 'Request should succeed' );
done_testing();

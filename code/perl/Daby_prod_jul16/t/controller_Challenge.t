use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Daby';
use Daby::Controller::Challenge;

ok( request('/challenge')->is_success, 'Request should succeed' );
done_testing();

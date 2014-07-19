use strict;
use warnings;

use Daby;

my $app = Daby->apply_default_middlewares(Daby->psgi_app);
$app;


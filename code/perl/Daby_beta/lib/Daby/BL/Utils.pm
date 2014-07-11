package Daby::BL::Utils;

sub sortUsers {
  my  $c = shift;

  my @users;
  for my $user ($c->model('DB::User')->fullSet) {
    push @users, { id => $user->id, name => $user->name };
  }

  my @sorted_users = sort { "\L$a->{name}" cmp "\L$b->{name}" } @users;

  my @rows;
  for my $user (@sorted_users) {
    push @rows, $c->model('DB::User')->byID($user->{id})->first;
  }

  return @rows;
}

1;

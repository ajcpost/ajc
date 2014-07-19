package Daby::BL::Utils;
use Daby::BL::Constants;

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

sub isUserLogged {
  my $c = shift;

  return 0 unless ($c->user_exists);
  my $row = $c->model('DB::User')->byID($c->user->id)->first;
  return 0 unless ($row);
  return 1;
}

sub canEditArticle {
  my $c = shift;
  my $aID = shift;

  my $row = $c->model('DB::Article')->byID($aID)->first;
  if ($row && 
      ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_SAVED) &&
      ($row->userid->id == $c->user->id || $c->user->isAdmin())) {
    return 1;
  }
  return 0;
}

sub canDeleteArticle {
  my $c = shift;
  my $aID = shift;

  my $row = $c->model('DB::Article')->byID($aID)->first;
  if ($row && 
      ($row->userid->id == $c->user->id || $c->user->isAdmin())) {
    return 1;
  }
  return 0;
}

sub canSubmitArticle {
  my $c = shift;
  my $aID = shift;

  my $row = $c->model('DB::Article')->byID($aID)->first;
  if ($row && 
      ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_SAVED) &&
      ($row->userid->id == $c->user->id || $c->user->isAdmin())) {
    return 1;
  }
  return 0;
}


sub canApproveArticle {
  my $c = shift;
  my $aID = shift;

  my $row = $c->model('DB::Article')->byID($aID)->first;
  if ($row &&
      ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_SUBMITTED ||
       $row->article_state == $Daby::BL::Constants::ARTICLE_STATE_PUBLISHED) &&
      ($c->user->isApprover())) {
    return 1;
  }
  return 0;
}

1;

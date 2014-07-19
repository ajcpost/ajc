use utf8;
package Daby::BL::Constants;

##### Constants, mostly for table schema 
our $USER_STATE_ACTIVE           = 0;
our $USER_STATE_INTERNAL         = -1;
our $USER_STATE_TEST             = -2;
our $USER_STATE_BANNED           = -99;

our $ROLE_ADMIN                  = "admin";
our $ROLE_APPROVER               = "approver";
our $ROLE_MEMBER                 = "member";

our $ARTICLE_TYPE_NORMAL         = 0;
our $ARTICLE_TYPE_TEST           = -1;

our $ARTICLE_STATE_SAVED         = 0;
our $ARTICLE_STATE_SUBMITTED     = 1;
our $ARTICLE_STATE_PUBLISHED     = 5;
our $ARTICLE_STATE_REVOKED       = -1;

our $COMMENT_STATE_PUBLISHED     = 0;
our $COMMENT_STATE_REVOKED       = -1;

our $STORE_LOCATION              = "/apps/Daby/my/store";

1;

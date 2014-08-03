use utf8;
package Daby::BL::ContentStore;
use Data::UUID;
use Daby::BL::Constants;
use File::Copy;
use File::Path;
use Catalyst::Log;

sub readContentFromFile {
  my $contentLocation = shift;

  my $rootDir  = $Daby::BL::Constants::STORE_LOCATION;
  my $filePath = $rootDir . "/" . $contentLocation;

  my $content="";
  my $FH;

  #$logger->debug ("Reading html content from location: " . $filePath);
  if (-f $filePath) {
      ### TBD: Need a more graceful way than die
      open $FH, "<", $filePath  or die $!;
      local $/;
      $content = <$FH>;
      close $FH;
  }
  return $content;
}

sub createContentLocation {

  ### Generate location using year, month and a unique ID.
  ### Someone creating an article at end of month midnight may
  ### have article location in a month earlier than create
  ### timestamp but is no loss in functionality.
  my $dt         = DateTime->now();
  my $subDir     = $dt->year . "/" . $dt->month();
  my $rootDir    = $Daby::BL::Constants::STORE_LOCATION;
  my $contentDir = $rootDir. "/". $subDir;

  #$logger->debug ("Content direcotry is: " . $contentDir);
  mkpath($contentDir) unless(-d $contentDir);

  my $uid             = Data::UUID->new->create_str();
  my $contentLocation = $subDir. "/". $uid;

  #$logger->debug ("Content location is: " . $contentLocation);
  return $contentLocation;
}

sub storeContentAsFile {
  my $content         = shift;
  my $contentLocation = shift;

  my $rootDir;
  my $filePath;
  if (!defined $contentLocation || $contentLocation eq "") {
      #$logger->debug ("Content location is not defined or empty, creating it");
      $rootDir  = $Daby::BL::Constants::STORE_LOCATION;
      $contentLocation = createContentLocation();
      $filePath = $rootDir . "/" . $contentLocation;
  }
  else {
      #$logger->debug ("Content location is defined, using it");
      $rootDir  = $Daby::BL::Constants::STORE_LOCATION;
      $filePath = $rootDir . "/" . $contentLocation;
  }
  
  ### In edit use case, file will exist, bak it up. This
  ### way we will always have previous version of the
  ### article.
  ### TBD: What if DB update fails after this? 
  if (-f $filePath) {
      rename ($filePath, $filePath . "_bak");
  }

  ### TBD: Need a more graceful way than die
  my $FH;
  open $FH, ">" , $filePath or die $!;
  print $FH $content . "\n";
  close $FH;
  return $contentLocation;
}

sub deleteFileContent {
  my $contentLocation = shift;

  if (!defined $contentLocation || $contentLocation eq "") {
    return;
  }

  #$logger->debug ("Content location is defined, using it");
  my $rootDir  = $Daby::BL::Constants::STORE_LOCATION;
  my $filePath = $rootDir . "/" . $contentLocation;
  my $bakFilePath = $filePath . "_bak";

  unlink $filePath, $bakFilePath;
}

sub generateSummary {
    my $content = shift;
    return unless $content;

    # eliminate html tags
    $content =~ s/<[^>]+>/ /g;
    # trim whitespace
    $content =~ s/\s{2,}/ /g;

    my $len = length $content;
    $content = substr($content, 0, 150) . ($len > 150 ? '...' : '');
    return $content;
}

1;

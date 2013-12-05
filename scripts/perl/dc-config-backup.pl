#!/usr/bin/perl -w
#
# $Id: //ariba/platform/tools/config/perl/dc-config-backup.pl#1 $
#
# Responsible: vipgupta
#
# Script to take backup of topology, server configurations, and database tables in 
# Dynamic Capacity Context. Useful for debugging the state of the cluster before or after
# a RR or RU run.

use strict;
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../lib", "$FindBin::Bin/../lib/perl");
use Getopt::Long;
use Cwd;
use ariba::rc::InstalledProduct;
use ariba::Ops::Startup::Common;
use ariba::rc::Globals;
use ariba::rc::Passwords;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Path;
use ariba::Ops::DBConnection;
use ariba::Ops::OracleClient;

# list of database tables which needs to be backed up should be mentioned here.
my @DbTablesToBackup = (
    "ClusterTransitionTab", 
    "BucketStateTab", 
    "CommunityTab");

sub main
{
    my ($product, $service, $directory) = @_;
    my $validOptions = GetOptions(
        'directory=s' => \$directory,
        'product=s' => \$product,
        'service=s' => \$service 
    );
    
    if(!defined $product || !defined $service || !$validOptions) {
        usage(); 
    }

    my $installedProduct = installedProduct($product, $service);    
    print "Creating backup of configuration for '$product' on '$service' \n";
        
    my $backupDir = createBackupDir($directory, $installedProduct);
    
    ariba::rc::Passwords::initialize($service);
    backupDatabaseTables($backupDir, $installedProduct);
    backupConfigurationFromWebServers($installedProduct, $backupDir);
    zip($backupDir);
    rmtree($backupDir);
}

sub createBackupDir
{
    my ($directory, $installedProduct) = @_;
    my $backupDir = $directory;
    if(!defined $backupDir) {
        $backupDir = ariba::Ops::Startup::Common::tmpdir();
    }
    my $time = time;
    $backupDir = "$backupDir/backup-$time";
    
    mkpath($backupDir) or die "Couldn't mkpath '$backupDir': $!\n";
    print "Backup Directory : $backupDir \n";

    return $backupDir;
}

# Backup the database tables specified in DbTablesToBackup array. 
# The contents of the corresponding tables are stored in the root of 
# the backup folder in a txt file having same name as the table. 
# Example:  for a table named 'CommunityTab' this will create a file 
# named CommunityTab.txt in the backup folder.  
sub backupDatabaseTables
{
    my ($backupDir, $installedProduct) = @_;
    my $sqlFile = "$backupDir/sql.txt";

    my ($tx) = ariba::Ops::DBConnection->connectionsFromProducts($installedProduct);
    my $oracleClient = ariba::Ops::OracleClient->new($tx->user(), $tx->password(), $tx->sid(), $tx->host());
    $oracleClient->connect();
    
    for my $tableName (@DbTablesToBackup) {
        my $headerSql = "SELECT column_name FROM all_tab_columns WHERE table_name = '" . uc($tableName) . "'";
        my $sql = "select * from $tableName";
        my $dataFile = "$backupDir/$tableName.txt";
        unless(open FILE, '>' . $dataFile) {
            print "Unable to create $dataFile. Please check your permissions and try again. \n";
            next;
        }
        my @headers = $oracleClient->executeSql ($headerSql);
        print FILE "$_\t" for @headers;
        print FILE "\n";
        my @data = $oracleClient->executeSql ($sql);
        print FILE "$_\n" for @data;
        close FILE;
    }
    $oracleClient->disconnect();
}

sub backupConfigurationFromWebServers
{
    my ($installedProduct, $backupDir) = @_;
    
    my $cluster = $installedProduct->currentCluster();
    my @webServerHosts = $installedProduct->hostsForRoleInCluster("httpvendor", $cluster);
    my $productName = $installedProduct->name();
    my $serviceName = $installedProduct->service();
        
    #location of files on the servers    
    my $rootDir = ariba::rc::Globals::rootDir("ssws", $installedProduct->service());
    my $configFilelocation = "$rootDir/config";
    my $topologyFileLocation = "$rootDir/docroot/topology/$productName";
    
    my $user = ariba::rc::Globals::deploymentUser($productName, $serviceName);

    for my $host (@webServerHosts) {
        print "Copying configuration files from Web server host : $host\n";
                
        my $currentDir="$backupDir/$host";
        my $configDirectory = "$currentDir/config";
        my $topologyDirectory = "$currentDir/topology";
                
        mkpath($currentDir) or die "Couldn't mkpath '$currentDir': $!\n";
        mkpath($topologyDirectory) or die "Couldn't mkpath '$topologyDirectory': $!\n";
        mkpath($configDirectory) or die "Couldn't mkpath '$configDirectory': $!\n";
        
        ariba::rc::Utils::transferFromSrcToDest($host, $user, $configFilelocation, undef, undef, $user, $configDirectory, undef, 0);
        ariba::rc::Utils::transferFromSrcToDest($host, $user, $topologyFileLocation, undef, undef, $user, $topologyDirectory, undef, 0);
    }
}

#zips the backup folder and prints out it location
sub zip
{
    my $directoryToZip = shift;
    my $zip = Archive::Zip->new();
    $zip->addTree($directoryToZip);
    # Save the Zip file
    unless ( $zip->writeToFileNamed("$directoryToZip.zip") == AZ_OK ) {
        die 'Error in creating zip file - Write error';
    }
    print "\n*******************************************************\n";
    print "Backup completed. \n";
    print "Backup file location :  $directoryToZip.zip";
    print "\n*******************************************************\n";
}

sub installedProduct {
    my ($productName, $service) = @_;
    my $product;
    if (ariba::rc::InstalledProduct->isInstalled($productName, $service)) {
        $product = ariba::rc::InstalledProduct->new($productName, $service);
    } else {
        die "Unable to find product: $productName on service : $service\n";
    }
    return $product;
}

sub usage {
    my $ver = '$Id: //ariba/platform/tools/config/perl/dc-config-backup.pl#1 $';
    print "usage: $0 (version $ver)\n";

    #config-backup -product buyer -service itg -directory /dynamic-capacity/config/backup
    print "usage: $0 -product <product name> -service<service> -directory <optional path to backup file>\n"; 
    print "    -product      : Required, Name of the product eg: buyer, s4\n"; 
    print "    -service      : Required, Service name Example:ITG or DEV3 \n"; 
    print "    -directory    : Optional, Directory where the backup zip file should be kept\n"; 
    exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR()); 
}

main();

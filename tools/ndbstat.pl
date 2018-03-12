#!/usr/bin/perl
#
# This program will read all data inside NDBINFO.counters and print
# out cumulative difference from last run, you can control interval
# with varible sleep.
#
# Author: Ted Wennmark, 2014
#

use DBI;
use Getopt::Long;
use Data::Dumper;
use File::Basename;
use List::MoreUtils qw( each_array );
use Storable qw(dclone);

# DEFAULT VALUES
my $sleep = 1;
my $host;
my $port;
my $user;
my $password;
my $debug = 0;
my $onlydiff=0;
my $help=0;

# ARGUMENT HANDLING
usage() if (@ARGV == 0);
if ( @ARGV > 0 ) {
	GetOptions ("sleep=i" => \$sleep,
		    "host=s" => \$host,
		    "port=s" => \$port,
		    "user=s" => \$user,
		    "password:s" => \$password,
		    "only-diff!" => \$onlydiff,
		    "help!" => \$help,
		    "verbose" => \$debug) or usage();
}
usage() if $help;

my $SELECT_STMT    = "SELECT block_name, node_id, counter_name, val FROM ndbinfo.counters";

########
# MAIN #
########
my $dbh = DBI->connect("DBI:mysql:database=ndbinfo;host=$host;port=$port",$user,$password,
			{'RaiseError' => 1, 'AutoCommit' => 0}) or die "\nDB connection error!\n";

my $sth = $dbh->prepare($SELECT_STMT) or die "Cannot prepare: " . $dbh->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();

my @row;
my @fields;
my @fields_next;
while(@row = $sth->fetchrow_array()) {
  my @record = @row;
  push(@fields, \@record);
}
$sth->finish();

while() {
   sleep(1);
   @fields_next=();

   $sth->execute() or die "Cannot execute: " . $sth->errstr();
   while(@row = $sth->fetchrow_array()) {
      my @record = @row;
      push(@fields_next, \@record);
   }

   my $it = each_array( @fields, @fields_next );
   while ( my ($x, $y) = $it->() ) {
      if (@$x[3] == 0) {
	next;
      }
      my $diff = @$y[3] - @$x[3];
      if ($onlydiff && ($diff == 0)) {
        next;
      }
      print "@$x[0](@$x[1]) @$x[2] = @$x[3] @$y[3] -> $diff\n";
   }
   print "####################################################################\n";
   @fields=();
   @fields = @{ dclone(\@fields_next) };
   $sth->finish();
}

$dbh->disconnect();
exit(0);

# FUNCTIONS
sub usage {
	my $scriptname = basename($0);
	printf("Usage: $scriptname --sleep <seconds> --host <host> --port <port> --user <user> --password [password] [--help] [--verbose] \n");
	printf("\t\t --seconds     - Number of seconds to sleep inbetween runs \n");
	printf("\t\t --host        - MySQL host to connect to \n");
	printf("\t\t --port        - Port number of MySQL instance \n");
	printf("\t\t --user        - MySQL user to connect as \n");
	printf("\t\t --password    - MySQL password to use \n");
	printf("\t\t --only-diff   - Only log changes in counters. \n");
	printf("\t\t --help        - Prints this help message. \n");
	printf("\t\t --verbose     - Print debug information \n");
	printf("\n");
	exit(1);
}

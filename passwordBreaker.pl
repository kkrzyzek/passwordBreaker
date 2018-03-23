#!/usr/bin/perl
#Krzysztof Krzyzek, 2018
use strict;
use warnings;

use Term::ANSIColor;
use Time::HiRes qw(time);
use threads qw[yield];
use threads::shared;
use FindBin '$Bin';

use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib $Bin;

use passwordMakerModul qw(randomPassMaker);

my $currentDir = abs_path;
#print $currentDir;

my $numArgs = $#ARGV + 1;
if ($numArgs == 0) {
	print color 'bold';
	printf "Error - no arguments. Exiting.\n";
	print color 'reset';
	exit 1;
}
elsif ($ARGV[0] eq "-g") {
	randomPassMaker($ARGV[1]);
}
elsif ($ARGV[0] eq "-h" or $ARGV[0] eq "--help") {
	print "@@@ HELP @@@\n";
	print ("**********************************************************\n");
	print "@@@ Krzysztof Krzyzek - 2018 @@@\nPASSWORD BREAKER\n";
	print ("**********************************************************\n");
	print "*Script has two functions:\n 1. Opening password protected .zip archives - (only 4 digit codes).\nCommand example: ./passwordBreaker.pl lockFolder1.zip lockFolder2.zip\nTo only break password (NOT open archive) add -p flag before archive name\nCommand example: ./passwordBreaker.pl -p lockFolder0.zip\nPasswords are being broken with brute force method.\n2. Module passwordMakerModul.pm is responsible for generating strong passwords (flag -g).\nCommand example: ./passwordBreaker.pl -g 15\nwhere 15 is a number of alphanumeric characters in generated password (default=10 characters).\n";
	print "**********************************************************\n\n";
	exit 0;
}

print "@@@ 4 DIGIT PASSWORD BREAKER @@@\n";
print "**********************************************************\n";
my @numbs = ("0" .. "9");
my $unzipFlag=0;
foreach my $argnum (0 .. $#ARGV) {
	
	my $lockFlag=1;
	if ($ARGV[$argnum] =~ /.zip$/) {
		print "Unlocking $ARGV[$argnum].\nPlease wait: ";
		my $start = time();

		my $ready: shared = 0;
		my $isOk: shared  = 0;
		async {
		  local $| = 1;
		  while (!$ready) {
		  	do {
		      select undef, undef, undef, 0.5;
		      printf "|" if ($isOk);
        }
		  }
		  $ready = 0;
		}
		->detach;
		
		my $archDirectory .= join "/", $Bin, $ARGV[$argnum];

		system("rm -rf tempExtract.XXX");
		#system("mktemp -d tempExtract.XXX");

		OUTER:
		for my $first(@numbs) {
			$isOk = 1;
			for my $second(@numbs) {
				for my $third(@numbs) {
					for my $fourth(@numbs) {

		        system(
		        	"unzip -qq -o -P $first$second$third$fourth $ARGV[$argnum] -d tempExtract.XXX > /dev/null 2>&1"
		        );
		        if (not $?) {
							$isOk = 0;
							$ready = 1;
							yield while $ready;
							#print $currentDir;
							my $end = time();

							if ($unzipFlag==0) {
								system("cp -a tempExtract.XXX/. $currentDir/");
								printf("\nUNLOCKED! Elapsed time: %.2fs", $end - $start);
								$lockFlag=0;
							}
							else {
								system("rm -rf tempExtract.XXX");

								$lockFlag=0;
								$unzipFlag=0;
								printf("\nFOUND PASSWORD! Elapsed time: %.2fs", $end - $start);
							}
							print color 'bold';
	            print "\nPassword to archive $ARGV[$argnum] is $first$second$third$fourth.\n";
							print color 'reset';
							print "**********************************************************\n";
							last OUTER;
		        }
		    	}
				}
			}
		}
	}
	elsif ($ARGV[$argnum] eq "-p") {
		$unzipFlag=1;	
		next;
	}
	else {
		$lockFlag=0;
		#sleep(2);
		print color 'bold';
		print "$ARGV[$argnum] - error, wrong argument type.\n";
		print color 'reset';
		print "**********************************************************\n";
	}

		if ($lockFlag == 1) {
		print color 'bold';		
		printf("\n$ARGV[$argnum] - failed to unlock archive.\n");
		print color 'reset';
		print "**********************************************************\n";	
	}		
}

exit 0;

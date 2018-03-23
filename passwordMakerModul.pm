package passwordMakerModul;
use strict;
use warnings;

use Term::ANSIColor;
use Exporter qw(import);
 
our @EXPORT_OK = qw(randomPassMaker);

sub randomPassMaker {
	print "@@@ STRONG PASSWORD MAKER @@@\n";

	my ($x) = @_;
	$x //= 10;

	if ($x =~ /^\d+?$/) {
		my @characters = ('a'..'z', 'A'..'Z', 0..9);
		my $randPass = join '', map $characters[rand @characters], 0..($x-1);

		if ($x == 1) {
			print color 'bold';
			print "Generated password with $x character: $randPass\n";
			exit 0;
		}
		elsif ($x > 1) {
			print color 'bold';
			print "Generated strong password with $x characters: $randPass\n";
			exit 0;
		}
	}
	
	print color 'bold';
	print "Error, wrong argument type.\n";
	exit 2;

}

1;

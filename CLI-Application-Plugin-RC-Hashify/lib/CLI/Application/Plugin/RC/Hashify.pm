
package CLI::Application::Plugin::RC::Hashify;

use strict;
use warnings;

use Tie::File::Hashify;

use CLI::Application::Plugin::RC;

our @ISA = qw( CLI::Application::Plugin::RC );


our $VERSION = '0.01';


sub _load_rc {
	my ($self, $path) = @_;

	my %rc;

	tie %rc, 'Tie::File::Hashify', $path, parse => \&_parse;

	$self->{rc} = { %rc };
}


sub _parse {
	my ($line) = @_;

	chomp $line;

	$line =~ s/#.*$//;
	
	if($line =~ /^\s*(\S+)\s*=\s*(.*?)\s*$/) {
		return ($1, $2);
	}

	return;
}


!0

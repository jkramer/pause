
package YAML::Repository;

use strict;
use warnings;

use Text::Repository;
use YAML qw( thaw );

our @ISA = qw( Text::Repository );


sub fetch {
	my ($self, $name) = @_;

	my $text = $self->SUPER::fetch($name);

	if(defined $text) {
		return thaw($text);
	}
	else {
		return;
	}
}


1

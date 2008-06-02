
package Net::Plazes::Plaze;

use strict;
use warnings;

use Carp;

our $AUTOLOAD;


my @FIELDS = qw(
	name category address city state zip_code country_code country
	timezone latitude longitude created_at updated_at
);

my @CATEGORIES = qw(
	airport bar club coffee_shop conference home hotel landmark
	movie_theater museum office other railway_station restaurant
	shop stadium theater university other
);

sub new {
	my ($class, %fields) = @_;

	return bless { map { $_ => $fields{$_} } @FIELDS }, $class;
}


sub category {
	my ($self, $category) = @_;

	$self->{category} = $category if($#_ > 0);

	$self->{category} = 'other' unless defined $self->{category};

	if(!grep { $self->{category} eq $_ } @CATEGORIES) {
		$self->{category} = 'other';
	}

	return $self->{category};
}


sub AUTOLOAD {
	my ($self, $value) = @_;

	my $field = (split /::/, $AUTOLOAD)[-1];

	if(grep { $field eq $_ } @FIELDS) {
		$self->{$field} = $value if($#_ == 2);
		return $self->{$field};
	}
	else {
		croak "No such field '$field'";
	}
}


!0;

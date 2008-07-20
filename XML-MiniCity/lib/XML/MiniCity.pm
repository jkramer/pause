
package XML::MiniCity;

use strict;
use warnings;

use XML::XPath;
use LWP::UserAgent;
use Carp;


our $VERSION = '0.01';
our $AUTOLOAD;


sub new {
	my ($class, $name) = @_;

	my @nodes = qw(
		host name region ranking population
		incomes unemployment transport criminality
		pollution nextnuke signatures
	);

	return bless {
		agent => new LWP::UserAgent,
		name => $name,
		nodes => \@nodes,
		data => { map { $_ => undef } @nodes },
	}, $class;
}


sub update {
	my ($self) = @_;

	my $url = 'http://' . $self->{name} . '.myminicity.com/xml';
	my $response = $self->{agent}->get($url);

	if($response->is_success) {
		my @nodes =

		my $xp = new XML::XPath(xml => $response->content);

		$self->{data}->{$_} = $xp->findvalue('/city/' . $_) for(@{$self->{nodes}});

		return 1;
	}

	return;
}


sub AUTOLOAD {
	my ($self) = @_;

	my ($method) = (split /::/, $AUTOLOAD)[-1];

	if(grep { $_ } @{$self->{nodes}}) {
		return $self->{data}->{$method};
	}
	else {
		croak "No such method ($method).\n";
	}
}


1


__END__


=head1 NAME

XML::MiniCity

=head1 SYNOPSIS

	my $city = new XML::MiniCity('mycity');
	die unless $city->update;

	print $city->host, "\n";
	print $city->unemployment, "\n";
	print $city->transport, "\n";
	# ...

=head1 DESCRIPTION

This is simple module to access the data of a city on B<myminicity.com>. It
fetches the XML data file of a given city and provides them via simple accessor
methods.

=head1 METHODS

=over 4

=item B<new>($cityname)

Creates a new city object. The parameter should be host part of your city URL,
for example if your city is at 'http://dokuleser.myminicity.com', then you
would use 'dokuleser' as city name.

=item B<update>

This method requests the XML data from the server. It returns a true value on
success, undef on error.

=item B<host>

=item B<name>

=item B<region>

=item B<ranking>

=item B<population>

=item B<incomes>

=item B<unemployment>

=item B<transport>

=item B<criminality>

=item B<pollution>

=item B<nextnuke>

=item B<signatures>

These are the accessor methods for XML nodes. Only getting, no setting.

=back

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer <jkramer@cpan.org>. Published under the
terms of the Artistic License 2.0.

=cut

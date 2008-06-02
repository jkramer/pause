
package Net::Plazes;

use strict;
use warnings;

use LWP::UserAgent;


our $VERSION = '0.01';


sub new {
	my ($class, $login, $password) = @_;

	croak "Need login and password" unless $login and $password;

	my $agent = new LWP::UserAgent(agent => "Net::Plazes/$VERSION");

	$agent->credentials('plazes.net:80', undef, $login, $password);

	return bless { agent => $agent }, $class;
}


sub plaze {
	my ($self) = @_;

	return new Net::Plazes::Plaze;
}


!0;

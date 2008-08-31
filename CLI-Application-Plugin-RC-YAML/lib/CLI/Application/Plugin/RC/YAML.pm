
package CLI::Application::Plugin::RC::YAML;

use strict;
use warnings;

use CLI::Application::Plugin::RC;
use YAML::Tiny;
use File::Slurp;

our @ISA = qw( CLI::Application::Plugin::RC );
our $VERSION = '0.01';


sub _load_rc {
	my ($self, $path) = @_;

	return $self->{rc} = thaw(slurp($path));
}


!0;


__END__

=head1 NAME

CLI::Application::Plugin::RC::YAML

=head1 SYNOPSIS

use CLI::Application;

my $app = new CLI::Application(
	...,
	plugins => [ qw( RC::YAML ) ],
	...,
);

...

my $rc = $app->rc;

=head1 DESCRIPTION

This is a plugin for B<CLI::Application> that looks for a YAML-formatted
configuration file at some common places (see L<CLI::Application::Plugin::RC>,
loads it and makes its contents available through the B<rc> method exported to
the application.

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer. Published under the terms of the Artistic
License 2.0.

=cut

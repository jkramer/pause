
package CLI::Application::Plugin::RC;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';


sub new {
	my $class = shift;

	return bless { @_ }, $class;
}


sub export {
	return qw( rc );
}


sub rc {
	my ($self, $application) = @_;

	if(!$self->{rc}) {
		my $path = $self->_find_rc($application->name);
		$self->_load_rc($path) if($path);
	}

	return $self->{rc};
}


sub _find_rc {
	my ($self, $name) = @_;

	my $basename = $name . '.rc';

	for("$ENV{HOME}/.", "$ENV{HOME}/.$name/", '/etc/') {
		my $path = $_ . $basename;
		return $path if(-r $path);
	}

	return;
}


sub _load_rc {
	my $class = ref($_[0]);
	croak "_load_rc ($class) must be overwritten.\n";
}


!0;


__END__

=head1 NAME

CLI::Application::Plugin::RC

=head1 SYNOPSIS

	use CLI::Application::Plugin::RC::YAML;

	use strict;
	use warnings;

	use YAML::Tiny;
	use CLI::Application::Plugin::RC;

	our @ISA = qw( CLI::Application::Plugin::RC );

	sub _load_rc {
		my ($self, $path) = @_;

		$self->{rc} = thaw(slurp($path));
	}

=head1 DESCRIPTION

This is a base class for L<CLI::Application> plugins that load configuration
files. If you want to write such a module, just inherit from this one and
overwrite the method B<_load_rc>, however, you can overwrite anything you want.
Below is a list of methods you may want to overwrite.

=head1 METHODS

=over 4

=item B<rc>

This method will be exported to the application object when your plugin is
loaded. It'll get the application object as argument when called. The default
method (if not overwritten) will check if B<$self->{rc}> is set. If not, it'll
call B<_find_rc> to detect a configuration file at common locations. If a
configuration is found, B<_load_rc> will be called with the path as argument.

Returns $self->{rc}.

=item B<_find_rc>

Try to find a configuration file at some common locations, based on the
application name. For example, if your application name is 'foo', it will look
out for '~/.foo.rc' and then '/etc/foo.rc'. If one of those files is found, its
path is returned, otherwise undef. If you want to look somewhere else, this
method. It will be called with the application name as argument.

=item B<_load_rc>

This method B<must> be overwritten, the default one will croak. It will be
called with the path of the configuration file as argument. It should the load
the configuration and put it in $self->{rc}.

=back

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer. Published under the terms of the Artistic
License 2.0.

=cut

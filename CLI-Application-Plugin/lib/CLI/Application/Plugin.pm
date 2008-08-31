
package CLI::Application::Plugin;

use strict;
use warnings;

our $VERSION = '0.01';

!0;

__END__

=head1 NAME

CLI::Application::Plugin

=head1 SYNOPSIS

	package CLI::Application::Plugin::UsefulPlugin;

	use strict;
	use warnings;

	use CLI::Application::Plugin;

	our @ISA = qw( CLI::Application::Plugin );

	sub export {
		return qw( hello );
	}

	sub hello {
		my ($self, $application) = @_;
		print "Moo!\n";
	}

	-----

	use CLI::Application;

	my $application = new CLI::Application(
		...
		plugins => [ qw( UsefulPlugin ) ],
		...
	);

	$application->prepare(@ARGV);
	$application->dispatch;

	sub moo : Command('Say moo!') : Fallback {
		my ($application) = @_;
		$application->hello;
	}

=head1 DESCRIPTION

Plugins are a way to extend B<CLI::Application> scripts with commonly used
functionality. To use plugins, give the application constructor a list of
plugins you want to load. You can either use the full module name or the module
name relative to B<CLI::Application::Plugin>.

To write your own plugins, use the namespace B<CLI::Application::Plugin>. Just
write your methods and add another method named B<export> that returns a list
with the names of the methods you want to plug into B<CLI::Application>. Make
sure you don't overwrite anything!

=cut

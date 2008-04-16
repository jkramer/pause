
package CLI::Application;

use strict;
use warnings;

no strict 'refs';

our $VERSION = '0.01';
our $data = undef;


sub new {
	my ($class, %rc) = @_;
	return bless \%rc, $class;
}


sub prepare {
	my ($self, @argv) = @_;

	my $wanted = $self->{options} || [];
	my @rest;
	my %option;

	while(my $arg = shift(@argv)) {
		# Save non-option arguments.
		if($arg =~ /^[^-]/) {
			push @rest, $arg;
		}

		# Save everything after '--'.
		elsif($arg eq '--') {
			push @rest, @argv;
			last;
		}

		# Get long options.
		elsif($arg =~ /^--(.+?)(?:=(.*))?$/) {
			my ($key, $value) = ($1, $2);
			my $option = $self->option($key);

			if($option->[2]) {
				$value = shift @argv unless defined $value;

				die $self->usage("Missing argument for option --$key.")
					unless(defined $value);

				$option{$_} = $value for(@{$option->[0]});
			}
			else {
				$option{$_} = !0 for(@{$option->[0]});
			}
		}

		# Get short options.
		elsif($arg =~ /^-([^-].*)$/) {
			my $all = $1;

			while($all) {
				$all =~ s/^(.)//;
				my $key = $1;

				my $option = $self->option($key);
				
				if($option->[2]) {
					if($all) {
						$option{$_} = $all for(@{$option->[0]});
						last;
					}
					else {
						my $value = shift @argv;

						die $self->usage("Missing argument for option -$key.")
							unless(defined $value);

						$option{$_} = $value for(@{$option->[0]});
					}
				}
				else {
					$option{$_} = !0 for(@{$option->[0]});
				}
			}
		}
		else {
			die "Don't know what to do with '$arg'.\n";
		}
	}

	my $command = (shift @rest) || $self->{fallback};

	die $self->usage("No action.") unless $command;

	my $caller = caller;

	my $code = *{$caller . '::' . $command}{CODE};
	if($code and $command =~ /^[^_]+/) {
		$self->action($command);
	}
	else {
		die $self->usage("No such command.");
	}

	$self->{parsed} = \%option;
	$self->{rest} = \@rest;
}

sub option {
	my ($self, $needle) = @_;

	my $list = $self->{options} || [];

	for my $option (@$list) {
		return $option if grep { $_ eq $needle } @{$option->[0]};
	}

	die $self->usage("Unknown option '$needle'.\n");
	exit -1;
}


sub usage {
	my ($self, @message) = @_;
	return "@message\n";
}


sub action {
	my ($self, $action) = @_;
	
	$self->{action} = $action if(defined $action);

	return $self->{action};
}


sub run {
	my ($self, $action) = @_;

	$action ||= $self->action;

	my $caller = caller;
	my $code = *{$caller . '::' . $action}{CODE};

	return &{$code}($action, $self->{parsed}, $self->{rest});
}

!0;

__END__

=head1 NAME

CLI::Application - create command line tools with less code

=head1 SYNOPSIS

	use CLI::Application;

	my $cli = new CLI::Application(
		name => 'test',
		version => '0.01',
		fallback => 'help',
		options => [
			[ [ qw( v verbose ), 'Be more verbose.' ] ],
			[ [ qw( f file ), 'Use the given file.', 'string' ] ],
		],
	);

	$cli->prepare(@ARGV);

	$cli->run;

	sub help {
		warn "Usage: $0 [-v|--verbose] [-f|--file some-file] foo|bar|help\n";
	}

	sub foo {
		my ($action, $options, $arguments) = @_;

		if($options->{verbose}) {
			warn "Being verbose!\n";
		}

		warn "Using file $options->{file}.\n" if $options->{file};
		warn "Action is 'foo'.\n";
	}

	sub bar {
		my ($action, $options, $arguments) = @_;

		if($options->{verbose}) {
			warn "Being verbose!\n";
		}

		warn "Using file $options->{file}.\n" if $options->{file};
		warn "Action is 'bar'.\n";
	}

=head1 DESCRIPTION

This module aims to reduce the overhead of writing/using option parsers for
command line tools.

=head1 METHODS

=over 4

=item B<new>(...)

Creates a new application object. Takes a hash with the needed configuration as
arguments. Following options are supported at the moment.

=over 4

=item * B<name>

This is the name of your application. It is currently not really used, but this
module probably will be able to generate usage and help messages using it.

=item * B<version>

See B<name>.

=item * B<fallback>

Allows you to specify a default action to call if no non-option argument is
given.

=item * B<options>

Array of arrays specifying the allowed options. Each array should have two or
three elements. The first element is another array with the possibly variations
of the option, without the dashes. Single characters are taken as short options
(single dash), anything long will be used as long option (two dashes). The
second element is a short line of text describing what the option is meant for.
This will be used in future help messages (see B<name> and B<version>). If
there is a third element, the application will expect an argument for the
option. Currently anything true works as third element. In future versions,
there will probably be a way to do argument validation using a special string
instead. See B<SYNOPSIS> for an example.

=back

=item B<prepare>(list of arguments, usually @ARGV)

This method parses the options from the given list of command line arguments.
It will die if there are problems (unknown option, missing argument, ...).

=item B<run>(no arguments)

Runs the application. Actually, this simply calls the appropriate function
based on the arguments and the fallback option.

=back

=head1 BUGS

If there are bugs, please report them.

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer <jkramer@pause.org>. Published under the
terms of the Artistic License 2.0.

=cut

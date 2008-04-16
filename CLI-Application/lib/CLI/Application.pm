
package CLI::Application;

use strict;
use warnings;

no strict 'refs';

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



=cut

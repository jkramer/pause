
package CLI::Application;

use strict;
use warnings;

use Carp;
use Attribute::Handlers;
use Text::Table;

our $VERSION = '0.01';

our %ACTION;
our $FALLBACK;


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
					unless defined $value;

				if(!$self->_validate_option($option->[2], $value)) {
					my $error = "Wrong argument for option --$key.";
					$error .= ' ' . $option->[3] if($option->[3]);
					die $self->usage($error);
				}

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

						if(!$self->_validate_option($option->[2], $value)) {
							my $error = "Wrong argument for option -$key.";
							$error .= ' ' . $option->[3] if($option->[3]);
							die $self->usage($error);
						}

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

	my $command = (shift @rest) || $FALLBACK;

	die $self->usage("No action.") unless $command;

	if($ACTION{$command}) {
		$self->action($command);

		$self->{parsed} = \%option;
		$self->{rest} = \@rest;
	}
	else {
		die $self->usage("No such command.");
	}
}


sub option {
	my ($self, $needle) = @_;

	my $list = $self->{options} || [];

	for my $option (@$list) {
		return $option if grep { $_ eq $needle } @{$option->[0]};
	}

	die $self->usage("Unknown option '$needle'.\n");
}


sub usage {
	my ($self, @message) = @_;

	my $usage = $self->_usage;

	return "@message\n\n$usage\n";
}


sub _usage {
	my ($self) = @_;

	my $usage = "Usage: $0 [options] <action>\n";

	if(%ACTION) {
		my $table = new Text::Table;

		while(my ($name, $hash) = each %ACTION) {
			$table->add("\t" . $name, '-- ' . $hash->{text});
		}

		$usage .= "\nACTIONS\n" . $table->table . "\n";
	}

	my $options = $self->_option_usage;
	$usage .= "\nOPTIONS\n$options\n" if($options);

	return $usage;
}


sub _option_usage {
	my ($self) = @_;

	if(@{$self->{options}}) {
		my $table = new Text::Table;

		for my $option (@{$self->{options}}) {
			my ($flags, $description, $validate) = @{$option};

			my @aliases;

			for my $flag (@{$flags}) {
				push @aliases, (length($flag) < 2 ? '-' : '--') . $flag;
			}

			$flags = join(' | ', @aliases);

			if($validate) {
				if(ref($validate)) {
					if(ref($validate) eq 'ARRAY') {
						$validate = '[' . join(' | ', @{$validate}) . ']';
					}
					else {
						$validate = '<...>';
					}
				}

				$flags .= ' ' . $validate;
			}

			$description ||= "Don't know what this option is good for.";

			$table->add(
				$flags,
				' -- ' . $description,
			);
		}

		return $table->table;
	}

	return '';
}


sub _validate_option {
	my ($self, $validate, $value) = @_;

	if(ref($validate)) {
		my $type = uc ref $validate;

		if($type eq 'ARRAY') {
			return grep { $_ eq $value } @{$validate};
		}

		elsif($type eq 'REGEXP' or $type eq 'SCALAR') {
			$validate = qr/${$validate}/ if($type eq 'SCALAR');

			return $value =~ $validate;
		}

		elsif($type eq 'HASH') {
			# Don't know what to do with hashes yet.
		}

		elsif($type eq 'CODE') {
			return &{$validate}($value);
		}
	}

	return !0;
}


sub action {
	my ($self, $action) = @_;

	if(defined $action and !$ACTION{$action}) {
		die "Unknown action '$action'.\n";
	}

	$self->{action} = $action if(defined $action);

	return $self->{action};
}


sub dispatch {
	my ($self, $action) = @_;

	$action ||= $self->action || $FALLBACK;

	my $code = $ACTION{$action}->{code};

	return &{$code}($action, $self->{parsed}, $self->{rest});
}


sub UNIVERSAL::Command : ATTR(CODE) {
	my ($package, $symbol, $code, $attribute, $data, $phase) = @_;

	$ACTION{*{$symbol}{NAME}} = {
		code => $code,
		text => ref($data)
			? $data->[0]
			: 'I have no idea what this action does.',
	};
}


sub UNIVERSAL::Fallback : ATTR(CODE) {
	my ($package, $symbol, $code, $attribute, $data, $phase) = @_;

	$FALLBACK = *{$symbol}{NAME};
}


!0;


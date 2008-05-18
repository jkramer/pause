
package Tie::File::Hashify;

use strict;
use warnings;

use Carp;
use IO::File;

our $VERSION = '0.02';


sub TIEHASH {
	my ($class, $path, $parse, $format) = @_;

	my $self = bless {
		hash => {},
		format => $format,
		path => $path,
		dirty => 0,
	}, $class;

	if($path and -e $path and $parse) {
		my $io = new IO::File($path) or croak "Can't read $path. $!.\n";

		while(my $line = $io->getline) {
			next unless defined $line and length($line);

			my ($key, $value);

			# Use callback for parsing.
			if(ref($parse) eq 'CODE') {
				($key, $value) = &{$parse}($line);
			}

			# Parse line using a regular expression.
			elsif(ref($parse) eq '' or uc(ref($parse)) eq 'REGEXP') {
				my $re = ref($parse) ? $parse : qr/^$parse$/;
				($key, $value) = ($line =~ $re);
			}

			# Croak.
			else {
				croak 'Can\'t use ', lc(ref($parse)), " for parsing.\n";
			}

			if(defined $key and length $key) {
				$self->{hash}->{$key} = $value if(length $key);
			}
		}

		$io->close;
	}

	return $self;
}


sub FETCH {
	my ($self, $key) = @_;
	return $self->{hash}->{$key};
}


sub STORE {
	my ($self, $key, $value) = @_;

	$self->{dirty} = !0;

	return $self->{hash}->{$key} = $value;
}


sub EXISTS {
	my ($self, $key) = @_;
	return exists($self->{hash}->{$key});
}


sub DELETE {
	my ($self, $key) = @_;

	$self->{dirty} = !0;

	return delete($self->{hash}->{$key});
}


sub CLEAR {
	my ($self) = @_;

	$self->{dirty} = !0;

	%{$self->{hash}} = ();
}


sub FIRSTKEY {
	my ($self) = @_;
	my ($key) = each %{$self->{hash}};
	return $key;
}


sub NEXTKEY {
	my ($self) = @_;

	my ($k, $v) = each %{$self->{hash}};

	return $k;
}


sub SCALAR {
	my ($self) = @_;

	my $format = $self->{format};

	if(defined $format) {
		my $text = '';

		values %{$self->{hash}};

		while(my ($key, $value) = each %{$self->{hash}}) {
			# Format using callback.
			if(ref($format) eq 'CODE') {
				$text .= &{$format}($key, $value) . "\n";
			}
			
			# Format using sprintf and a format string.
			elsif(ref($format) eq '') {
				$text .= sprintf($format, $key, $value) . "\n";
			}

			# Croak.
			else {
				croak 'Can\'t use ' . ref($format) . " as format.\n";
			}
		}

		return $text;
	}

	else {
		return %{$self->{hash}};
	}
}


sub _store {
	my ($self) = @_;

	my $path = $self->{path};

	if($path and $self->{dirty} and $self->{format}) {
		my $io = new IO::File('>' . $path) or croak "Can't write $path. $!.\n";

		$io->print($self->SCALAR);
		$io->close;

		$self->{dirty} = 0;
	}
}


sub UNTIE {
	my ($self) = @_;

	$self->_store;
}


sub DESTROY {
	my ($self) = @_;

	$self->_store;
}


!0;

__END__

=head1 NAME

TIe::File::Hashify - Parse a file and tie the result to a hash.

=head1 SYNOPSIS

	use Tie::File::Hashify;

	my %rc;
	my $path = "$ENV{HOME}/.some.rc";

	# Parse lines like 'foo = bar':
	sub parse { $_[0] =~ /^\s*(\S+)\s*=\s*(.*?)\s*$/ };

	# Format pairs as 'key = value':
	sub format { "$_[0] = $_[1]" };

	tie(%rc, 'Tie::File::Hashify', $path, \&parse, \&format);

	print "option 'foo' = $rc{foo}\n";

	# Add new option.
	$rc{bar} = 'moo';

	# Save file.
	untie %rc;

=head1 DESCRIPTION

This module helps parsing simple text files and mapping it's contents to a
plain hash. It reads a file line by line and uses a callback or expression you
provide to parse a key and a value from it. The key/value pairs are then
available through the generated hash. You can also provide another callback or
format string that formats a key/value pair to a line to be stored back to the
file.

=head1 METHODS

=over 4

=item B<tie>(%hash, $path, \&parse, \&format)

The third argument (after the hash itself and the package name of course) is
the path to a file. The file does not really have to exist, but using a path to
a non-existent file does only make sense if you provide a format-callback to
write a new file.

The third argument is used for parsing the file. It may either be code
reference, which will be called with a line as argument and should return the
key and the value for the hash element; or it may be a string or compiled
regular expression (qr//). The expression will be applied to every line and $1
and $2 will be used as key/value afterwards.

The fourth argument is used for formatting the hash into something that can be
written back to the file. It may be a code reference that takes two arguments
(key and value) as arguments and returns a string (without trailing line-break
- it will be added automatically), or a format string that is forwarded to
B<sprintf> together with the key and the value.

All arguments (B<path>, B<parse>, B<format>) each may be omitted / undef. If
you omit all of them, you get a plain normal hash.

=back

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer <jkramer@cpan.org>. Published under the
terms of the Artistic License 2.0.

=cut


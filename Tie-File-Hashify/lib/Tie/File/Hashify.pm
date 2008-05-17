
package Tie::File::Hashify;

use strict;
use warnings;

use Carp;
use IO::File;

our $VERSION = '0.01';


sub TIEHASH {
	my ($class, $path, $parse, $format) = @_;

	croak "No parse callback.\n" unless $parse;

	my $self = bless {
		hash => {},
		parse => $parse,
		format => $format,
		path => $path,
		dirty => 0,
	}, $class;

	if(-e $path) {
		my $io = new IO::File($path) or croak "Can't read $path. $!.\n";

		while(my $line = $io->getline) {
			next unless defined $line and length($line);

			my ($key, $value) = &{$parse}($line);

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
	return delete($self->{hash}->{$key});
}


sub CLEAR {
	my ($self) = @_;
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


sub _store {
	my ($self) = @_;

	if($self->{dirty} and $self->{format}) {
		my $path = $self->{path};
		my $io = new IO::File('>' . $path) or croak "Can't write $path. $!.\n";

		while(my ($key, $value) = each %{$self->{hash}}) {
			$io->say(&{$self->{format}}($key, $value));
		}

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
plain hash. It reads a file line by line and calls a callback you provide to
parse a key and a value from the file. The key/value pairs are then available
through the generated hash. You can also provide another callback that formats
a key/value pair to a line to be stored back to the file.

=head1 METHODS

=over 4

=item B<tie>(%hash, $path, \&parse, \&format)

The first argument is the hash you want to tie to the file. The second one is
the path to a file. The file does not really have to exist, but using a path to
a non-existent file does only make sense if you provide a format-callback to
write a new file. The third argument is the callback function that is called
for every line of the parsed file. It gets the currently read line as argument
and should return two scalars (key and value). If the first return value (the
key) is B<undef> or empty (''), nothing is added to the hash.
The fourth argument is another callback. If it's provided, it will be called
for every key/value pair in the hash when the tied hash is untied. It gets the
key and the value of the current pair as arguments and should return a string,
which then will be saved to the file.

The parse callback and the format callback may be omitted. If you omit both,
you get a plain hash that does nothing special.

=back

=head1 TODO

=over 4

=item * Allow regex instead of parse callback for parsing.

=item * Allow format instead of format callback for formatting.

=back

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer <jkramer@cpan.org>. Published under the
terms of the Artistic License 2.0.

=cut


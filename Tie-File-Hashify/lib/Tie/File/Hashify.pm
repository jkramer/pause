
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

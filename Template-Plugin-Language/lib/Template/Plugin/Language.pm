
package Template::Plugin::Language;

use strict;
use warnings;

use Template::Plugin::Filter;

our @ISA = qw( Template::Plugin::Filter );

our $VERSION = '0.01';

=head1 NAME

Template::Plugin::Language - Filter plugin for multilingual templates.

=head1 SYNOPSIS

	[% USE Language %]
	[% FILTER $Language 'DE' %]

	<LANG:DE>Guten Tag!</LANG:DE>
	<LANG:EN>Ahoy!</LANG:EN>
	<LANG:FR>Bonjour!</LANG:FR>
	<LANG:KLINGON>NUQNEH!!</LANG:KLINGON>

	[% END %]

	Output:

	Guten Tag!

	---

	wrapper.tmpl:

	[% USE Language %]
	[% FILTER $Language 'EN' %]
	[% content %]
	[% END %]


	other.tmpl:

	[% WRAPPER 'wrapper.tmpl' %]
	<LANG:DE>Foo!</LANG:DE>
	<LANG:EN>Bar!</LANG:DE>
	...
	[% PROCESS 'another.tmpl' %]
	...
	<LANG:DE>Baz!</LANG:DE>
	<LANG:EN>Quux!</LANG:EN>
	[% END %]

=head1 DESCRIPTION

This is a pretty simple filter plugin I wrote because I wanted easy
internationalization in my templates. It takes a similar approach as
L<Template::Multilingual>, but it works as a plugin for the "normal"
L<Template> framework, and it is a bit more programmer-friendly as you can put
the filter in a wrapper and therefore localize your whole site in one shot, and
it supports any number of language tags in a filter block.

=head1 BUGS

Please report bugs in the CPAN bug tracker.

=head1 COPYRIGHT

Copyright (C) 2008 by Jonas Kramer. Published under the terms of the Artistic
License 2.0.

=cut


sub init {
	my $self = shift;
	$self->{_DYNAMIC} = 1;
	return $self;
}


sub filter {
	my ($self, $text, $arguments) = @_;

	my $language = shift @{$arguments};

	if($language) {
		$text =~ s{<LANG:(\w+)>(.*?)<\/LANG:\1>}{$1 eq $language ? $2 : ''}segi;
	}
	else {
		warn "No language selected in " . __PACKAGE__ . "!\n";
	}

	return $text;
}


1

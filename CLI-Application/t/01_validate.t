
use strict;
use warnings;

use Test::More tests => 10;

use CLI::Application;


my $cli = new CLI::Application(
	name => 'test',
	version => '0.01',
	fallback => 'main',
	options => [
		# Any argument is fine.
		[ [ qw( v value ) ], 'Option with argument.', !0 ],

		# Must be 'foo' or 'bar'.
		[ [ qw( f foobar ) ], 'Foobar.', [ qw( foo bar ) ], 'not foo or bar' ],

		# Must be numeric.
		[ [ qw( n number ) ], 'Numeric.', qr/^\d+$/, 'not numeric' ],

		# Must be numeric.
		[ [ qw( N number2 ) ], 'Numeric.', \'^\d+$', 'not numeric' ],

		# Must be an existing file.
		[ [ qw( F file ) ], 'File.', sub { -f $_[0] }, 'not existing' ],
	],
);


SKIP: {
	eval { $cli->prepare(qw(-v)); };
	ok($@, 'missing argument');
}

ok($cli->prepare('-F', $0), 'file existing');

SKIP: {
	eval { $cli->prepare(qw(-F file_that_hopefully_does_not_exist)) };
	ok($@ =~ /not existing/, 'file not existing');
}

ok($cli->prepare(qw(-n 15)), 'numeric regexp');

SKIP: {
	eval { $cli->prepare(qw(-n abc)) };
	ok($@ =~ /not numeric/, 'not numeric regexp');
}

ok($cli->prepare(qw(-N 15)), 'numeric scalar');

SKIP: {
	eval { $cli->prepare(qw(-N abc)) };
	ok($@ =~ /not numeric/, 'not numeric scalar');
}

ok($cli->prepare(qw(-f foo)), 'foo');
ok($cli->prepare(qw(-f bar)), 'bar');

SKIP: {
	eval { $cli->prepare(qw(-f baz)) };
	ok($@ =~ /not foo or bar/, 'not foo or bar');
}

sub main {}

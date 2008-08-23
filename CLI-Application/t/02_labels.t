
use strict;
use warnings;

use Test::More;

use CLI::Application;

my $cli = new CLI::Application(
	name => 'test',
	version => '0.01',
	fallback => 'main',
	options => [
		[ [ qw( t test ) ], 'Test option.' ],
		[ [ qw( v value ) ], 'Option with argument.', !0 ],
	],
);

sub main : Command {
	print "MAIN!\n";
}

sub foo : Command("The FOO function!") {
	print "FOO!\n";
}

sub bar {
	print "NO BAR!\n";
}

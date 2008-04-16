
use strict;
use warnings;

use Test::More tests => 19;

use CLI::Application;


my $cli = new CLI::Application(
	name => 'test',
	version => '0.01',
	fallback => 'main',
	options => [
		[ [ qw( t test ) ], 'Test option.' ],
		[ [ qw( v value ) ], 'Option with argument.', 'string' ],
	],
);

ok($cli->prepare(qw()), 'first prepare');
ok($cli->run, 'first run');

ok($cli->prepare(qw(--test --value=foo test)), 'second prepare');
ok($cli->run, 'second run');

ok($cli->prepare(qw(-t -v foo test)), 'second prepare');
ok($cli->run, 'third run');

sub main {
	my ($action, $options, $arguments) = @_;

	ok(!0, 'default action called');

	return !0;
}

sub test {
	my ($action, $options, $arguments) = @_;

	ok(!0, 'test action called');
	ok($action eq 'test', 'action');

	ok($options->{test}, 'long test option set');
	ok($options->{t}, 'short test option set');

	ok($options->{value} eq 'foo', 'long option with argument ok');
	ok($options->{v} eq 'foo', 'short option with argument ok');

	return !0;
}

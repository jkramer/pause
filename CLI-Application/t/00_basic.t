
use strict;
use warnings;

use Test::More tests => 31;

use CLI::Application;


my $cli = new CLI::Application(
	name => 'test',
	version => '0.01',
	options => [
		[ [ qw( t test ) ], 'Test option.' ],
		[ [ qw( v value ) ], 'Option with argument.', !0 ],
	],
);

ok($cli->prepare(qw()), '1st prepare');

ok($cli->dispatch, '1st run');

ok($cli->prepare(qw(--test --value=foo test)), '2nd prepare');
ok($cli->dispatch, '2nd run');

ok($cli->prepare(qw(-t -v foo test)), '3rd prepare');
ok($cli->dispatch, '3rd run');

ok($cli->prepare(qw(-t -vfoo test)), '4th prepare');
ok($cli->dispatch, '4th run');

ok($cli->prepare(qw(-tvfoo test)), '5th prepare');
ok($cli->dispatch, '5th run');

sub main : Command("Moo!") : Fallback {
	my ($app) = @_;

	ok(!0, 'default action called');

	return !0;
}

sub test : Command("Blah!")  {
	my ($app) = @_;

	ok(!0, 'test action called');

	ok($app->option('test'), 'long test option set');
	ok($app->option('t'), 'short test option set');

	ok($app->option('value') eq 'foo', 'long option with argument ok');
	ok($app->option('v') eq 'foo', 'short option with argument ok');

	return !0;
}

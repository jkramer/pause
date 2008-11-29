
use strict;
use warnings;

use Module::Build;

my $build = new Module::Build(
	module_name => 'Template::Plugin::Language',
	license => 'artistic_2',
	requires => {
		perl => '5.8.8',
		Template => undef,
	},
);

$build->create_build_script;

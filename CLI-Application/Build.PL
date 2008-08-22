
use Module::Build;

my $build = new Module::Build(
	module_name => 'CLI::Application',
	license => 'artistic2',
	requires => { perl => '5.8', },
);

$build->create_build_script;

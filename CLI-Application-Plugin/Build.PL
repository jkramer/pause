
use Module::Build;

my $build = new Module::Build(
	module_name => 'CLI::Application::Plugin',
	license => 'artistic_2',
	requires => {
	},
);

$build->create_build_script;

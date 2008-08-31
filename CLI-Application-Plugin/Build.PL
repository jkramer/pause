
use Module::Build;

my $build = new Module::Build(
	module_name => 'CLI::Application::Plugin',
	license => 'artistic_2',
	requires => {
		perl => '5.8.5',
		'CLI::Application' => '0.02',
	},
);

$build->create_build_script;

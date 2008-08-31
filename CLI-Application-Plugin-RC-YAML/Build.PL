
use Module::Build;

my $build = new Module::Build(
	module_name => 'CLI::Application::Plugin::RC::YAML',
	license => 'artistic_2',
	requires => {
		perl => '5.8.5',
		'File::Slurp' => 0,
		'YAML::Tiny' => 0,
		'CLI::Application::Plugin::RC' => 0,
	},
);

$build->create_build_script;

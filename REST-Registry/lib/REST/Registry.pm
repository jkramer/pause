
package REST::Registry;

use strict;
use warnings;

use Carp;


my %RESOURCE = ();


sub PATH {
	my ($class, $path) = @_;

	# Get calling package to register.
	my $module = caller;

	# Search HTTP methods in caller package.
	my %methods = map {
		$_ => $module->can($_)
	} qw( GET POST PUT DELETE OPTIONS HEAD );

	# Extract named parameters from path and prepare for use as regular
	# expression.
	my @chunks;
	push @chunks, $1 while($path =~ m{(?:^|/)\%(.+?)(?:/|$)}g);

	$path =~ s{(^|/)\%.+?(/|$)}{$1(.+?)$2}g;

	# Register module in registry hash.
	$RESOURCE{$path} = {
		methods => \%methods,
		path => qr|$path|,
		module => $module,
		chunks => \@chunks,
	};
}


sub DISPATCH {
	my ($class, $cgi) = @_;

	my $request = $cgi->url(-absolute => !0, -path => !0);

	$request =~ s{^/*}{/};
	$request =~ s{/*$}{/};

	my $method = uc $cgi->request_method;

	# Find first module that registered a matching path.
	my ($path) = grep { $request =~ m{^$RESOURCE{$_}->{path}$} } keys %RESOURCE;
	
	# No match.
	return 404 unless $path;

	# Method not implemented.
	return 501 unless($method = $RESOURCE{$path}->{methods}->{$method});

	# Extract named parameters from path.
	my %chunks;
	(@chunks{@{$RESOURCE{$path}->{chunks}}}) = ($request =~ qr/^$path$/);

	# Prepare an instance of the class.
	my $module = $RESOURCE{$path}->{module};
	my $instance = $module->can('new') ? $module->new($cgi) : $module;

	# Do method-independent preparation stuff.
	$instance->prepare if($instance->can('prepare'));

	# Run method handler, assume it returns a HTTP status code.
	return &{$method}($instance, $cgi, \%chunks);
}


!0;


use strict;
use warnings;

use Test::More tests => 2;

use Template;
use Template::Plugin::Language;

my $text = '
[% USE Language %]
[% FILTER $Language language %]
<LANG:EN>foo</LANG:EN>
<LANG:DE>bar</LANG:DE>
[% END %]
';

my $template = new Template(
	{
		POST_CHOMP => 1,
		PRE_CHOMP => 1,
	}
);

my $output;
my $result = $template->process(\$text, { language => 'DE' }, \$output);

ok($output =~ /^\s*bar\s*$/, 'de tag works');

$output = '';
$result = $template->process(\$text, { language => 'EN' }, \$output);

ok($output =~ /^\s*foo\s*$/, 'en tag works');


use strict;
use warnings;

use Net::Plazes;
use IO::Prompt;

my $login = prompt -p 'plazes login: ';
my $password = prompt -p 'password: ', -e '*';

my $plazes = new Net::Plazes($login, $password);

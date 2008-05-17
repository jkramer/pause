#!/usr/bin/perl

use strict;
use warnings;

use Tie::File::Hashify;

my %rc,
tie %rc, 'Tie::File::Hashify', { /^\s*(\S+)\s*=\s*(\S)\s$/ }, { defined $_[1] ? "$_[0] = $_[1]" : undef };

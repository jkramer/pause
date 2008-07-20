#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;

use XML::MiniCity;

my $city = new XML::MiniCity('dokuleser');

ok($city, 'object created');
ok($city->update, 'object updated');

ok(defined $city->host, 'host is set');
ok(defined $city->name, 'name is set');
ok(defined $city->region, 'region is set');
ok(defined $city->ranking, 'ranking is set');
ok(defined $city->population, 'population is set');
ok(defined $city->incomes, 'incomes is set');
ok(defined $city->unemployment, 'unemployment is set');
ok(defined $city->transport, 'transport is set');
ok(defined $city->criminality, 'criminality is set');
ok(defined $city->pollution, 'pollution is set');
ok(defined $city->nextnuke, 'nextnuke is set');
ok(defined $city->signatures, 'signatures is set');

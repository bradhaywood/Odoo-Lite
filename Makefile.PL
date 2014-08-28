use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Odoo-Lite';
all_from 'lib/Odoo/Lite.pm';
author   q{Brad Haywood <brad@geeksware.com>};
license  'perl_5';

perl_version 5.010;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Odoo-Lite',
   #license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/Brad Haywood/Odoo-Lite.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Odoo-Lite',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   'JSON::RPC::Client' => 0,
   'Frontier::Client' => 0,
   'Moo' => 0,
);

install_as_cpan;
auto_install;
WriteAll;

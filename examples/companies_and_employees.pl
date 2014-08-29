#!/opt/perl5/bin/perl
use warnings;
use strict;
use Data::Dumper;
use 5.010;
use Odoo::Lite;

my $odoo = Odoo::Lite->new(
    user => 'admin',
    passwd => 'password',
    dbname => 'openerp',
    host   => 'localhost',
    proto  => 'jsonrpc',
    definitions => 'Odoo::Lite::Definitions',
)->connect;

my $companies = $odoo->companies;

for my $company ($companies->all) {
    say $company->{name};
    for my $employee ($odoo->employees($company, ['name'])) {
        if ($odoo->is_result($employee)) {
            say " - " . $employee->first->{name};
        } else {
            say " - No employee(s) found";
        }
    }
}

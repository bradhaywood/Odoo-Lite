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

$odoo->model('res.partner');

for my $c ($odoo->companies->all) {
    say $c->{name};
    for my $e ($odoo->employees($c)) {
        if (my $user = $odoo->find(['name'], $e)) {
            say " - $user->{name}";
        }
    }
}

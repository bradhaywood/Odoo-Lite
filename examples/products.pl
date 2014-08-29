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

my $products  = $odoo->products;

for my $product ($products->all) {
    say $product->{display_name};
}

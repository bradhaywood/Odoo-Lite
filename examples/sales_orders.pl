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
    definitions => 'Odoo::Lite::Definitions',
)->connect;

$odoo->model('res.partner');
my $partners = $odoo->search(
    ['id', 'email', 'name', 'parent_id'],
    ['id', '=', 1],
);

my $orders = $odoo->active_sales_orders($partners->first);

if ($orders->size > 0) {
    say  "=> There are " . $orders->size . " active Sales Orders";

    for my $order ($orders->all) {
        say $order->{name} . ' - £' . $order->{amount_total} . ' [' . $order->{state} . ']';
    }
} else {
    say "=> Found no active sales orders";
}

package Odoo::Lite::Definitions::Role::Sales;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'active_sales_orders' => (
    as      => 'sale.order',
    default => sub {
        my ($self, $args) = @_;
        unless ($args and ref $args eq 'HASH' and $args->{id}) {
            die "active_sales_orders() expects hash ref with 'id'";
        }

        return $self->search(
            ['state', 'user_id', 'partner_id', 'name', 'amount_total', 'date_order'],
            [['state', 'not in', ['draft', 'sent', 'cancel']], ['user_id', '=', $args->{id}]],
        );
    },
);

1;
__END__

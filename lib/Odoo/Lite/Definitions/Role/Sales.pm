package Odoo::Lite::Definitions::Role::Sales;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'active_sales_orders' => (
    as      => 'sale.order',
    default => sub {
        my ($self, $user) = @_;
        unless ($user and $user->{id}) {
            die "active_sales_orders() Not a valid user object passed";
        }

        return $self->search(
            ['state', 'user_id', 'partner_id', 'name', 'amount_total', 'date_order'],
            [['state', 'not in', ['draft', 'sent', 'cancel']], ['user_id', '=', $user->{id}]],
        );
    },
);

1;
__END__

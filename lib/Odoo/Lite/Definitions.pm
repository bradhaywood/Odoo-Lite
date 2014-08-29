package Odoo::Lite::Definitions;

use Odoo::Lite 'Definition';

has_def 'companies' => (
    as      => 'res.partner',
    default => sub {
        my ($self) = @_;
        return $self->search(
            ['email', 'name', 'is_company', 'child_ids'],
            ['is_company', '=', 1]
        );
    },
);

has_def 'employees' => (
    as      => 'res.partner',
    default => sub {
        my ($self, $company) = @_;
        unless ($company->{is_company}) {
            warn $company->{name} . " is not a valid company!";
            return 0;
        }

        if ($self->proto eq 'jsonrpc') {
        }

        return @{$company->{child_ids}};
    },
);

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

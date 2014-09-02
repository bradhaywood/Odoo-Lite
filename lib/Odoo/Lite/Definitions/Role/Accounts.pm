package Odoo::Lite::Definitions::Role::Accounts;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'accounts' => (
    as      => 'account.account',
    default => sub {
        my ($self, $id, $new_fields) = @_;
        my $fields = ['code', 'company_currency_id', 'company_id', 'parent_id', 'debit', 'type', 'name', 'credit', 'balance', 'child_id'];
        if ($new_fields) {
            for my $f (@$new_fields) {
                push @$fields, $f
                    unless grep { $_ eq $f } @$fields;
            }
        }

        return $self->clone->model('account.account')->search(
            $fields,
            [['child_id', '=', $id], ['code', '!=', '0']]
        ); 
    },
);

1;
__END__

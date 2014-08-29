package Odoo::Lite::Definitions::Role::Partners;

use Mouse::Role;
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
        my ($self, $company, $fields) = @_;
        $fields //= ['name', 'email'];
        unless ($company->{is_company}) {
            warn $company->{name} . " is not a valid company!";
            return 0;
        }

        if ($self->proto eq 'jsonrpc') {
            if (ref $company eq 'HASH' and $company->{child_ids}) {
                return $self->search(
                    $fields,
                    [ map { ['id', '=', $_] } @{$company->{child_ids}} ],
                );
            }
        }

        return @{$company->{child_ids}};
    },
);

1;
__END__

package Odoo::Lite::Definitions::Role::Partners;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'partners'  => (
    as      => 'res.partner',
    default => sub {
        my ($self, $fields) = @_;
        return $self->search(
            $fields,
            ['id', '>', 0],
        );
    },
);

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

has_def 'company' => (
    as      => 'res.partner',
    default => sub {
        my ($self, $user) = @_;
        my $fields = [ map { $_ } keys %$user ];
        unless ($user->{parent_id}) {
            die "Can't retrieve company for " . $user->{name} . " without parent_id being set!";
        }

        return $self->search(
            $fields,
            [['is_company', '=', 1], ['id', '=', $user->{parent_id}->[0]]],
        )->first;
    },
);

1;
__END__

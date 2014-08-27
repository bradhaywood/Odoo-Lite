package Odoo::Lite::Definitions;

use Odoo::Lite 'Definition';

has_def 'companies' => (
    as      => 'res.partner',
    default => sub {
        my ($self) = @_;
        return $self->search(['is_company', '=', 1]);
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

        return @{$company->{child_ids}};
    },
);

1;
__END__

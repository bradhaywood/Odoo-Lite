package Odoo::Lite::Definitions;

use Odoo::Lite 'Definition';

has_def 'companies' => (
    as      => 'res.partner',
    default => sub {
        my ($self) = @_;
        return $self->search(['is_company', '=', 1]);
    },
);

1;
__END__

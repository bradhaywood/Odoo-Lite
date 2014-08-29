package Odoo::Lite::Definitions::Role::Products;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'products' => (
    as      => 'product.template',
    default => sub {
        my ($self) = @_;
        return $self->search(
            [qw/
                name virtual_available product_variant_count lst_price sale_ok display_name
                qty_available type product_variant_ids uom_id is_product_variant __last_update
            /],
            ['sale_ok', '=', 1],
        );
    },
);

1;
__END__

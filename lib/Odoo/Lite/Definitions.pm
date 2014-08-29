package Odoo::Lite::Definitions;

use Odoo::Lite 'Definition';
use Mouse;
with qw/
    Odoo::Lite::Definitions::Role::Partner
    Odoo::Lite::Definitions::Role::Sales
/;

1;
__END__

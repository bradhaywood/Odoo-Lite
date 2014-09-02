package Odoo::Lite::Definitions;

use Mouse;
with qw/
    Odoo::Lite::Definitions::Role::Partners
    Odoo::Lite::Definitions::Role::Products
    Odoo::Lite::Definitions::Role::Accounts
    Odoo::Lite::Definitions::Role::Sales
/;

1;
__END__

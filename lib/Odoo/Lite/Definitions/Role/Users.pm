package Odoo::Lite::Definitions::Role::Users;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'authenticate' => (
    as      => 'res.users',
    default => sub {
        my ($self, $args) = @_;
        my ($email, $pass) = ( $args->{username}, $args->{password} );
        my $res =  $self->_execute_jsonrpc('authenticate', [$email, $pass]);
        if ($res->{uid}) {
            return $res;
        }

        return;
    },
);

1;
__END__

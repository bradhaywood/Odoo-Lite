package Odoo::Lite::Definitions::Role::Users;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'authenticate' => (
    as      => 'res.users',
    default => sub {
        my ($self, $email, $pass) = @_;
        my $check = $self->search(
            ['email', 'password'],
            #[['email', '=', $email], ['password', '=', $pass]],
            ['email', '=', $email],
        );
        
        if ($check->size > 0) { return $check->first; }
    },
);

1;
__END__

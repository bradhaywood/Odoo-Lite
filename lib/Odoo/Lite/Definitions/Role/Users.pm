package Odoo::Lite::Definitions::Role::Users;

use Mouse::Role;
use Odoo::Lite 'Definition';

has_def 'authenticate' => (
    as      => 'res.users',
    default => sub {
        my ($self, $args) = @_;
        my ($email, $pass) = ( $args->{username}, $args->{password} );
        my $check = $self->search(
            [qw/
                signup_valid
                alias_id
                signup_url
                company_id
                alias_domain
                company_ids
                name
                notify_email
                display_groups_suggestions
                partner_id
                state
                email
                action_id
                active
                tz
                signature
                login
                image
                display_employees_suggestions
                id
                alias_name
                alias_contact
                default_section_id
                lang
                display_name
                password
            /],
            [['login', '=', $email], ['password', '=', $pass]],
        );
        
        if ($check->size > 0) { return $check->first; }
    },
);

1;
__END__

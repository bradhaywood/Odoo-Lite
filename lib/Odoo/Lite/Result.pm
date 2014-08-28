package Odoo::Lite::Result;

use Moo;
extends 'Odoo::Lite::Functions';

has 'size'      => ( is => 'ro' );
has 'records'    => ( is => 'ro', default => sub { [] } );

sub all {
    my ($self) = @_;

    if (wantarray) { return @{$self->records}; }
    return $self->records;
}

1;
__END__

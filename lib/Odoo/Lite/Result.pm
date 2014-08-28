package Odoo::Lite::Result;

use Mouse;
extends 'Odoo::Lite::Functions';
with 'Odoo::Lite::Common';

has 'size'       => ( is => 'ro' );
has 'records'    => ( is => 'ro', default => sub { [] } );

sub all {
    my ($self) = @_;

    if (wantarray) { return @{$self->records}; }
    return $self->records;
}

sub first {
    my ($self) = @_;
    if ($self->size > 0) { return $self->records->[0]; }
    return 0;
}

sub update {
    my ($self, $args) = @_;
    $self->_execute_jsonrpc(
        'write',
        [ map { $_->{id} } @{$self->records} ],
        $args,
    );
}

1;
__END__

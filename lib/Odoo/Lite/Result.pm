package Odoo::Lite::Result;

use Mouse;
extends 'Odoo::Lite::Functions';
with 'Odoo::Lite::Common';

has 'size'       => ( is => 'ro' );
has 'records'    => ( is => 'rw', default => sub { [] } );

sub all {
    my ($self) = @_;

    if (wantarray) { return @{$self->records}; }
    return $self->records;
}

sub first {
    my ($self) = @_;
    if (@{$self->records}) { return $self->records->[0]; }
    return 0;
}

sub update {
    my ($self, $args) = @_;
    my $new_records = $self->records;
    for (my $i = 0; $i < @{$self->records}; $i++) {
        for my $key (keys %$args) {
            $new_records->[$i]->{$key} = $args->{$key};
        }
    }
    
    $self->records($new_records);

    $self->_execute_jsonrpc(
        'write',
        [ map { $_->{id} } @{$self->records} ],
        $args,
    );
}

1;
__END__

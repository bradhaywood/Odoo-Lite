package Odoo::Lite::Common;

use Mouse::Role;

has '_model'  => ( is => 'rw' );
has '_server' => ( is => 'rw' );
has '_server_object' => ( is => 'rw' );
has 'host'   => ( is => 'ro', required => 1 );
has 'user'   => ( is => 'ro', required => 1 );
has 'passwd' => ( is => 'ro', required => 1 );
has 'dbname' => ( is => 'ro', required => 1 );
has 'port'   => ( is => 'ro', default => sub { 8069 } );
has 'proto'  => ( is => 'ro', default => sub { 'jsonrpc' } );
has 'jid'    => ( is => 'rw', default => sub { 1 } );
has 'base'   => ( is => 'rw', default => sub { "http://localhost:8069" } );
has 'context' => ( is => 'rw', default => sub { {} } );
has 'session_id' => ( is => 'rw' );
has '_uid' => ( is => 'rw' );
has 'error' => ( is => 'rw' );
1;
__END__

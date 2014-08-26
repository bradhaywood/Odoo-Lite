package Odoo::Lite;

our $VERSION = '0.001';

use Moo;
use Frontier::Client;
extends 'Odoo::Lite::Functions';

has '_model'  => ( is => 'rw' );
has '_server' => ( is => 'rw' );
has '_server_object' => ( is => 'rw' );
has 'host'   => ( is => 'ro', required => 1 );
has 'user'   => ( is => 'ro', required => 1 );
has 'passwd' => ( is => 'ro', required => 1 );
has 'dbname' => ( is => 'ro', required => 1 );
has 'port'   => ( is => 'ro', default => sub { 8069 } );

sub connect {
    my ($self, %args) = @_;
    my $port = $self->port;
    my $host = $self->host;
    my $user = $self->user;
    my $pass = $self->passwd;
    my $dbname = $self->dbname;

    if ($user and $pass and $host and $port and $dbname) {
        my $server = Frontier::Client->new({ url => "http://${host}:${port}/xmlrpc/common" });
        my $server_object = Frontier::Client->new({ url => "http://${host}:${port}/xmlrpc/object" });
        $self->_server($server);
        $self->_server_object($server_object);
    } else {
        die "Missing parameters";
    }

    return $self;
}

sub model {
    my ($self, $model) = @_;
    $self->_model($model);
    return $self;
}

sub clone {
    my ($self) = @_;
    return Odoo::Lite->new(
        host => $self->host,
        user => $self->user,
        passwd => $self->passwd,
        dbname => $self->dbname,
        port => $self->port
    )->connect;
}

sub _model_check {
    my ($self) = @_;
    die "No model set\n"
        unless $self->_model;
}

=head1 NAME

Odoo::Lite - Odoo API calls made easy

=head1 DESCRIPTION

This module attempts to make interfacing with the Odoo RPC-XML API extremely easy, with as less fuss as possible.

=head1 SYNOPSIS

  use Odoo::Lite;
  
  # create the connection
  my $odoo = Odoo::Lite->new(
      host   => 'localhost',
      user   => 'admin',
      passwd => 'password',
      dbname => 'openerp_db'
  )->connect;

  # get a list of all the parners email addresses
  for my $id ($odoo->model('res.partner')->search) {
      if (my $user = $odoo->find($id)) {
          say $user->{email};
      }
  }

=head1 METHODS

=head2 connect

Actually performs the connection based on the parameters you gave to C<new>. Returns an instance of Odoo::Lite.

=head2 model

Sets the model for your Odoo::Lite instance.

  $odoo->model('ir.model');
  $odoo->model('res.partner');

=head2 clone

Clones your instance, re-using the same connection but allows you to set a new model (so you don't have to keep switching).

  $odoo->model('res.partner');
  my $models = $odoo->clone->model('ir.model');

In the example above, C<$models> now contains a brand new instance, but using the C<ir.model> model instead.

=head2 Searching, Updating, Inserting, Removing, etc

Please see the L<Odoo::Lite::Functions> module for the API method sugar.

=head1 AUTHOR

Brad Haywood <brad@geeksware.com>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
__END__

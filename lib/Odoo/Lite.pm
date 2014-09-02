package Odoo::Lite;

our $VERSION = '0.001';

use Mouse;
use JSON::RPC::Client;
extends 'Odoo::Lite::Functions';
with 'Odoo::Lite::Common';

sub import {
    my ($class, $arg) = @_;
    if ($arg and $arg eq 'Definition') {
        my $caller = caller;
        importdefs: {
            no strict 'refs';
            *{"${caller}::has_def"} = \&_has_def;
        }
    }

    # could not find a way to get JSON::RPC::Client to set headers
    # for the cookie, so let's hack^H^H^H^Hfix it
    fixjsonrpc: {
        no strict 'refs';
        no warnings 'redefine';
        *{"JSON::RPC::Client::new"} = sub {
            my $proto = shift;
            my $headers = shift;
            my $self  = bless {}, (ref $proto ? ref $proto : $proto);

            my $ua  = LWP::UserAgent->new(
                agent   => 'JSON::RPC::Client/' . $JSON::RPC::Client::VERSION . ' beta ',
                timeout => 10,
            );

            if ($headers) {
                $ua->default_header(%{$headers});
            }

            $self->ua($ua);
            $self->json( $proto->create_json_coder );
            $self->version('1.1');
            $self->content_type('application/json');

            return $self;
        };
    } #endfixjsorpc
}

sub _has_def {
    my ($method, %args) = @_;
    my $as      = delete $args{as};
    my $default = delete $args{default};
    
    if ($as and $default) {
        importdef: {
            no strict 'refs';
            *{"Odoo::Lite::${method}"} = sub {
                my ($self, $args) = @_;
                if (not $self->_model) { $self->_model($as); }
                unless ($self->_model eq $as) {
                    $self->_model($as);
                }

                $default->($self, $args);
            };
        }
    }
}

sub BUILDARGS {
    my ($class, %args) = @_;
    my $conf = delete $args{config};
    if ($conf) {
        my $config = do "$conf";
        map { $args{$_} = $config->{$_} } keys %$config;
    }
    
    my $defs = delete $args{definitions};
    
    if ($defs) {
        eval "use $defs";
        if ($@) {
            die "Failed to import definition module $defs: $@";
        }
    }
 
    return \%args;
}

sub connect {
    my ($self, %args) = @_;
    my $port = $self->port;
    my $host = $self->host;
    my $user = $self->user;
    my $pass = $self->passwd;
    my $dbname = $self->dbname;
    my $proto  = $self->proto;

    if ($user and $pass and $host and $port and $dbname) {
        if ($proto eq 'jsonrpc') {
            $self->_server(JSON::RPC::Client->new);
            my $auth = {
                db       => $dbname,
                login    => $user,
                password => $pass,
                base_location => "http://${host}:${port}",
                context  => {},
            };
            
            my $uri = "http://${host}:${port}/web/session/authenticate";
            my $res = $self->_server->call(
                $uri,
                {
                    id => $self->jid,
                    jsonrpc => '2.0',
                    method  => 'call',
                    params  => $auth,
                }
            );
        
            if (exists $res->{content}->{result}->{user_context}) {
                $self->base("http://${host}:${port}");
                $self->context($res->{content}->{result}->{user_context});
                $self->session_id($res->{content}->{result}->{session_id});
                $self->_uid($res->{content}->{result}->{uid});
                $self->_server(JSON::RPC::Client->new({ 'Cookie' => 'session_id=' . $self->session_id }));
            } else {
                die "Failed to connect to jsonrpc";
            } 
        }
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

sub is_result {
    my ($self, $obj) = @_;
    if (ref $obj eq 'Odoo::Lite::Result') { return 1; }
    return;
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

You can also reuse an entire connection config by creating a file with a hash ref and referencing that like so

  # config.pl
  {
      host   => 'localhost',
      user   => 'admin',
      passwd => 'password',
      dbname => 'openerp_db'
  }

  # odoo.pl
  my $odoo = Odoo::Lite->new(config => 'config.pl');

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

=head1 DEFINITIONS

Say you don't want a bunch of ugly multidimensional array searches in your code. You can separate these into 
definition modules. Odoo::Lite comes with a simple one called Odoo::Lite::Definitions, but you can make your own..

  package My::Odoo::Definitions;

  use Odoo::Lite 'Definition';

  has_def 'companies' => (
      as      => 'res.partner',
      default => sub {
          my ($self) = @_;
          return $self->search(['is_company', '=', 1]);
      },
  );

  has_def 'employees' => (
      as      => 'res.partner',
      default => sub {
          my ($self, $company) = @_;
          unless ($company->{is_company}) {
              warn $company->{name} . " is not a valid company!";
              return 0;
          }

          return @{$company->{child_ids}};
      },
  );

You can call the definition module whatever you like, then to use it, just pass it to the constructor

  my $odoo = Odoo::Lite->new(
      host   => 'localhost',
      user   => 'admin',
      passwd => 'password',
      dbname => 'openerp_db',
      definitions => 'My::Odoo::Definitions',
  )->connect;

  $odoo->model('res.partner');

  for my $id ($odoo->companies) {
      if (my $comp = $odoo->find($id)) {
          say $comp->{name};
          for my $cid ($odoo->employees($comp)) {
              if (my $employee = $odoo->find($cid)) {
                  say " - " . $employee->{name} . " <" . $employee->{email} . ">";
              }
          }
      }
  }

=head1 AUTHOR

Brad Haywood <brad@geeksware.com>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
__END__

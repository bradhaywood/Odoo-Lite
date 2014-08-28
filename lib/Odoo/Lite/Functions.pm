package Odoo::Lite::Functions;

=head1 NAME

Odoo::Lite::Functions - Module containing methods for Odoo::Lite

=head1 DESCRIPTION

This is where the methods for API calls to Odoo happen. Most of these methods will require a model set first 

  $odoo->model('model_name')

=head1 METHODS

=cut

our $VERSION = '0.001';

use Mouse;
use Odoo::Lite::Result;

=head2 uid

Returns the UID of the user. Mainly used for executing commands behind the scenes

  return $odoo->uid;

=cut

sub uid {
    my ($self) = @_;
    return $self->_server->call(
        'login',
        $self->dbname,
        $self->user,
        $self->passwd
    );
}

sub _execute {
    my $self = shift;
    if ($self->proto eq 'jsonrpc') {
        $self->_execute_jsonrpc(@_);
    } else {
        $self->_execute_xmlrpc(@_);
    }
}

sub _execute_jsonrpc {
    my ($self, $method, $fields, $domain, $offset, $limit) = @_;
    $offset //= 0;
    $limit //= 0;
    
    if ($method eq 'search_read') {
        unless (ref $domain->[0] eq 'ARRAY') { $domain = [ $domain ]; }
    } 
   
    my $uid = $self->_uid;
    my %args = (
        id      => $uid,
        jsonrpc => '2.0',
        method  => 'call',
        params  => {
            context => $self->context,
            domain  => $domain, 
            model   => $self->_model,
            fields  => $fields,
            offset  => $offset,
            limit   => $limit,
        },
    );

    if ($method eq 'write') {
        delete $args{params}{fields};
        delete $args{params}{domain};
        delete $args{params}{offset};
        delete $args{params}{limit};
        my $context = delete $args{params}{context};
        $args{params}{args} = [$fields, $domain];
        $args{params}{kwargs}{context} = $context;
        $args{params}{method} = 'write';
    }

    my $uri = $self->base . "/web/dataset/" . $method;
    if ($method eq 'write') { $uri = $self->base . "/web/dataset/call_kw/" . $self->_model . "/${method}"; }

    my $res = $self->_server->call(
        $uri, 
        \%args,
    );

    if ($res->is_success) {
        return Odoo::Lite::Result->new(
            size    => $res->{content}->{result}->{length},
            records => $res->{content}->{result}->{records},
            dbname  => $self->dbname,
            host    => $self->host,
            user    => $self->user,
            passwd  => $self->passwd,
            _server => $self->_server,
            _uid    => $self->_uid,
            context => $self->context,
            _model  => $self->_model,
        );        
    }
}

sub _execute_xmlrpc {
    my ($self, $method, @args) = @_;
    $self->_model_check();

    return $self->_server_object->call(
        'execute',
        $self->dbname,
        $self->uid,
        $self->passwd,
        $self->_model,
        $method,
        @args,
    );
}

=head2 find

Retrieves an object based on a single id

  my $user = $odoo->find(1);
  say $user->{email};

=cut

sub find {
    my ($self, $fields, $id) = @_;
    if ($self->proto eq 'jsonrpc') {
        my $f =  $self->search_read(
            $fields,
            ['id', '=', $id],
            0,
            1
        );

        if ($f->size > 0) {
            return $f->all->[0];
        }
    }

    return $self->_execute('read', $id); 
}

=head2 search

Perform a query based on an array of arguments. It will return an array or arrayref depending 
on where its target variable is to be held.

  my @ids = $odoo->search(['id', '=', 36]);
  my @coms = $odoo->search(['email', 'ilike', '.com']);

  # grab all the ids from the model
  my @all = $odoo->search();

  # limit to first result only
  my @first = $odoo->search(['email', 'ilike', '.com'], 0, 1);

  # query two separate fields
  my @admin = $odoo->search([ ['email', '=', 'you@yourcompany.com'], ['id', '=', 1] ]);

=cut

sub search_read {
    my ($self, $fields, $args, $offset, $limit) = @_;
    $self->_execute('search_read', $fields, $args, $offset, $limit);
}

sub search {
    my ($self, $fields, $args, $offset, $limit) = @_;
    if ($self->proto eq 'jsonrpc') {
        return $self->search_read($fields, $args, $offset, $limit);
    }

    my $res;
    if ($args) {
        if ($limit) {
            if (ref $args->[0] eq 'ARRAY') {
                $res = $self->_execute('search', $args, $offset, $limit);
            }
            else {
                $res = $self->_execute('search', [ $args ], $offset, $limit);
            }
        }
        else {
            if (ref $args->[0] eq 'ARRAY') {
                $res = $self->_execute('search', $args);
            }
            else {
                $res = $self->_execute('search', [ $args ]);
            }
        }
    }
    else {
        $res = $self->_execute('search', []);
    }

    if (wantarray) { return @{$res} }
    
    return $res;
}

=head2 create

Insert a new entry into the current model

  my $new_user = $odoo->model('res.partner')->create({
      name   => 'Mandy Moneymatters',
      email  => 'mandy.moneymatters@example.com',
      active => 1,
  });

  say $new_user->{name} . " was created";

Returns the new object on creation

=cut
      
sub create {
    my ($self, $args) = @_;
    return $self->find($self->_execute('create', $args));
}

=head2 delete

Removes entries based on an array ref of ids

    $odoo->delete([5, 7, 10]);

=cut

sub delete {
    my ($self, $ids) = @_;
    $self->_execute('unlink', $ids);
    return $self;
}

=head2 inject

Injects a custom method. Keep in mind it will use the currently selected model.

    my $partner_rs = $odoo->model('res.partner');
    $partner_rs->inject('first_of_coms', sub {
        my ($self) = @_;
        return $self->search(['email', 'ilike', '.com'], 0, 1);
    });

    for my $id ($partner_rs->first_of_coms) {
        say $id;
    }

=cut
        
sub inject {
    my ($self, $name, $fn) = @_;
    my $model = $self->_model;
    importfunc: {
        no strict 'refs';
        *{"Odoo::Lite::${name}"} = sub {
            my ($me, @args) = @_;
            if ($me->_model ne $model) {
                die "Can't call $name on model $model";
            }

            $fn->($me, @args);
        };
    }
}

=head2 update

Updates records based on an array ref of ids

    $odoo->update([1], {
        email => 'new@email',
        name  => 'New Name',
    });

=cut

sub update {
    my ($self, $ids, $params) = @_;
    return $self->_execute('write', $ids, $params);
}

=head2 fields

Retrieve information on the models fields

=cut

sub fields {
    my ($self) = @_;
    return $self->_execute('fields_get');
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.com>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
__END__

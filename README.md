# NAME

Odoo::Lite - Odoo API calls made easy

# DESCRIPTION

This module attempts to make interfacing with the Odoo RPC-XML API extremely easy, with as less fuss as possible.

# SYNOPSIS

```perl
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
```

# METHODS

## connect

Actually performs the connection based on the parameters you gave to `new`. Returns an instance of Odoo::Lite.

## model

Sets the model for your Odoo::Lite instance.

```
$odoo->model('ir.model');
$odoo->model('res.partner');
```

## clone

Clones your instance, re-using the same connection but allows you to set a new model (so you don't have to keep switching).

```perl
$odoo->model('res.partner');
my $models = $odoo->clone->model('ir.model');
```

In the example above, `$models` now contains a brand new instance, but using the `ir.model` model instead.

## Searching, Updating, Inserting, Removing, etc

Please see the [Odoo::Lite::Functions](https://metacpan.org/pod/Odoo::Lite::Functions) module for the API method sugar.

# DEFINITIONS

Say you don't want a bunch of ugly multidimensional array searches in your code. You can separate these into 
definition modules. Odoo::Lite comes with a simple one called Odoo::Lite::Definitions, but you can make your own..

```perl
package My::Odoo::Definitions;

use Odoo::Lite 'Definition';

has_def 'companies' => (
    as      => 'res.partner',
    default => sub {
        my ($self) = @_;
        return $self->search(['is_company', '=', 1]);
    },
);
```

You can call the definition module whatever you like, then to use it, just pass it to the constructor

```perl
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
}
```

# AUTHOR

Brad Haywood <brad@geeksware.com>

# LICENSE

You may distribute this code under the same terms as Perl itself.

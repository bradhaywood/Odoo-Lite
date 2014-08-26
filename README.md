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

# AUTHOR

Brad Haywood <brad@geeksware.com>

# LICENSE

You may distribute this code under the same terms as Perl itself.

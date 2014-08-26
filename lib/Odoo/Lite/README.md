# NAME

Odoo::Lite::Functions - Module containing methods for Odoo::Lite

# DESCRIPTION

This is where the methods for API calls to Odoo happen. Most of these methods will require a model set first 

```
$odoo->model('model_name')
```

# METHODS

## uid

Returns the UID of the user. Mainly used for executing commands behind the scenes

```
return $odoo->uid;
```

## find

Retrieves an object based on a single id

```perl
my $user = $odoo->find(1);
say $user->{email};
```

## search

Perform a query based on an array of arguments. It will return an array or arrayref depending 
on where its target variable is to be held.

```perl
my @ids = $odoo->search(['id', '=', 36]);
my @coms = $odoo->search(['email', 'ilike', '.com']);

# grab all the ids from the model
my @all = $odoo->search();

# limit to first result only
my @first = $odoo->search(['email', 'ilike', '.com'], 0, 1);

# query two separate fields
my @admin = $odoo->search([ ['email', '=', 'you@yourcompany.com'], ['id', '=', 1] ]);
```

## create

Insert a new entry into the current model

```perl
my $new_user = $odoo->model('res.partner')->create({
    name   => 'Mandy Moneymatters',
    email  => 'mandy.moneymatters@example.com',
    active => 1,
});

say $new_user->{name} . " was created";
```

Returns the new object on creation

## delete

Removes entries based on an array ref of ids

```
$odoo->delete([5, 7, 10]);
```

## inject

Injects a custom method. Keep in mind it will use the currently selected model.

```perl
my $partner_rs = $odoo->model('res.partner');
$partner_rs->inject('first_of_coms', sub {
    my ($self) = @_;
    return $self->search(['email', 'ilike', '.com'], 0, 1);
});

for my $id ($partner_rs->first_of_coms) {
    say $id;
}
```

## update

Updates records based on an array ref of ids

```perl
$odoo->update([1], {
    email => 'new@email',
    name  => 'New Name',
});
```

## fields

Retrieve information on the models fields

# AUTHOR

Brad Haywood <brad@geeksware.com>

# LICENSE

You may distribute this code under the same terms as Perl itself.

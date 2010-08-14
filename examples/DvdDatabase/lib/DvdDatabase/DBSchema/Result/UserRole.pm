package DvdDatabase::DBSchema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user",
  {
    data_type => "INTEGER",
    default_value => "'0'",
    is_nullable => 0,
    size => undef,
  },
  "role",
  {
    data_type => "INTEGER",
    default_value => "'0'",
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("user", "role");
__PACKAGE__->belongs_to("user", "DvdDatabase::DBSchema::Result::User", { id => "user" });
__PACKAGE__->belongs_to("role", "DvdDatabase::DBSchema::Result::Role", { id => "role" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-16 17:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I7p+Rv8oCe1opFxCXOVNdw


# You can replace this text with custom content, and it will be preserved on regeneration
use overload '""' => sub {$_[0]->id}, fallback => 1;

1;

package DvdDatabase::DBSchema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';
__PACKAGE__->load_components('EncodedColumn', "InflateColumn::DateTime", "Core");
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "username",
  {
    data_type => "VARCHAR",
    default_value => "NULL",
    is_nullable => 1,
    size => 255,
  },
  'password' => {
      data_type   => 'CHAR',
      size        => 40 + 10,
      encode_column => 1,
      encode_class  => 'Digest',
      encode_args   => {algorithm => 'SHA-1', format => 'hex', salt_length => 10},
      encode_check_method => 'check_password',
   },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "NULL",
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "dvd_owners",
  "DvdDatabase::DBSchema::Result::Dvd",
  { "foreign.owner" => "self.id" },
);
__PACKAGE__->has_many(
  "dvd_current_borrowers",
  "DvdDatabase::DBSchema::Result::Dvd",
  { "foreign.current_borrower" => "self.id" },
);
__PACKAGE__->has_many(
  "user_roles",
  "DvdDatabase::DBSchema::Result::UserRole",
  { "foreign.user" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-16 17:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ESCNnLy5mnVkTZJlB8IsKw


# You can replace this text with custom content, and it will be preserved on regeneration
use overload '""' => sub {$_[0]->username}, fallback => 1;
__PACKAGE__->many_to_many('roles', 'user_roles' => 'role');

1;

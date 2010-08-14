package DvdDatabase::DBSchema::Result::UnicodeExamples;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("unicode_examples");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "iso_country_code",
  { data_type => "CHAR", default_value => undef, is_nullable => 1, size => 2 },
  "language_name",
  {
    data_type => "varchar",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "main_unicode_set",
  {
    data_type => "varchar",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "example_text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-16 17:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ir2IaYyjcI4Kvrb0bZ9tIQ


# You can replace this text with custom content, and it will be preserved on regeneration
use overload '""' => sub {$_[0]->language_name}, fallback => 1;

1;

package DvdDatabase::DBSchema::Result::Dvdtag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("dvdtag");
__PACKAGE__->add_columns(
  "dvd",
  {
    data_type => "INTEGER",
    default_value => "'0'",
    is_nullable => 0,
    size => undef,
  },
  "tag",
  {
    data_type => "INTEGER",
    default_value => "'0'",
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("dvd", "tag");
__PACKAGE__->belongs_to("dvd", "DvdDatabase::DBSchema::Result::Dvd", { id => "dvd" });
__PACKAGE__->belongs_to("tag", "DvdDatabase::DBSchema::Result::Tag", { id => "tag" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-16 17:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8ORWqxYKxkfoxPBWSdb4vw


# You can replace this text with custom content, and it will be preserved on regeneration
use overload '""' => sub {$_[0]->id}, fallback => 1;

1;

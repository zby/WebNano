package DvdDatabase::DBSchema::Result::Dvd;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("dvd");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "NULL",
    is_nullable => 1,
    size => 255,
  },
  "imdb_id",
  {
    data_type => "INTEGER",
    default_value => "NULL",
    is_nullable => 1,
    size => undef,
  },
  "owner",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "current_borrower",
  {
    data_type => "INTEGER",
    default_value => "NULL",
    is_nullable => 1,
    size => undef,
  },
  "creation_date",
  {
    data_type => "date",
    default_value => "NULL",
    is_nullable => 1,
    size => undef,
  },
  "alter_date",
  {
    data_type => "datetime",
    default_value => "NULL",
    is_nullable => 1,
    size => undef,
  },
  "hour",
  {
    data_type => "time",
    default_value => "NULL",
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("owner", "DvdDatabase::DBSchema::Result::User", { id => "owner" });
__PACKAGE__->belongs_to(
  "current_borrower",
  "DvdDatabase::DBSchema::Result::User",
  { id => "current_borrower" },
);
__PACKAGE__->has_many(
  "dvdtags",
  "DvdDatabase::DBSchema::Result::Dvdtag",
  { "foreign.dvd" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-16 17:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UoDXZVFJ2iiSBDyuryAqgA


# You can replace this text with custom content, and it will be preserved on regeneration
use overload '""' => sub {$_[0]->name}, fallback => 1;
__PACKAGE__->many_to_many('tags', 'dvdtags' => 'tag');

1;

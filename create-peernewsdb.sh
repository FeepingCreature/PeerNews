#!/bin/sh
PEERNEWSDB="peernews.db"
# TODO export first
rm "$PEERNEWSDB"
cat <<EOT |
-- some tables have an id primary key
-- that id is NEVER sent over the network!
-- it is only for more efficient foreign keys
-- so, each table also has a "network key" (nk) which is marked unique
-- and identifies the record globally.
create table identity (
  id integer primary key not null,
  pk text unique not null, -- network key
  nick text,
  address text
);
create table content (
  id integer primary key not null,
  hash text unique not null, -- network key
  data text
);
create table post (
  id integer primary key not null,
  poster integer not null,
  body integer not null,
  parent integer,
  -- utc
  created datetime not null default (datetime('now')),
  -- an edit is a response to a comment by the same author marked "edit"
  edits integer not null default (1),
  foreign key(poster) references identity(id),
  foreign key(body) references content(id),
  foreign key(parent) references post(id),
  unique(poster, parent, created) -- network key
);
create table rating (
  id integer primary key not null,
  rater_id integer not null,
  post_id integer not null,
  rating real not null,
  foreign key(rater_id) references identity(id),
  foreign key(post_id) references post(id),
  unique(rater_id, post_id) -- foreign nk (rater nk, post nk)
);
create table peers (
  id integer primary key not null,
  peer_id integer not null,
  trust real not null,
  foreign key(peer_id) references identity(id)
);
create table toplevelpost (
  id integer primary key not null,
  title text not null,
  link text,
  foreign key(id) references post(id)
);
EOT
sqlite3 "$PEERNEWSDB"

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
create table post (
  id integer primary key not null,
  poster integer not null,
  created datetime not null default (datetime('now')), -- utc
  received datetime not null, -- time received (for incremental updates)
  parent integer,
  
  content text,
  signature text, -- parent sig/date/content signed by poster pk
  
  -- an edit is a response to a comment by the same author marked "edit"
  edits integer not null default (0),
  
  foreign key(poster) references identity(id),
  foreign key(parent) references post(id),
  unique(poster, created) -- network key
);
create table rating (
  id integer primary key not null,
  rater_id integer not null,
  post_id integer not null,
  rating integer not null,
  signature text not null, -- pk/post signature/rating, checked on receive
  foreign key(rater_id) references identity(id),
  foreign key(post_id) references post(id),
  unique(rater_id, post_id) -- foreign nk (rater nk, post nk)
);
create table peers (
  id integer primary key not null,
  peer_id integer not null,
  trust real not null,
  foreign key(peer_id) references identity(id),
  unique(peer_id)
);
create table toplevelpost (
  id integer primary key not null,
  title text not null,
  link text,
  foreign key(id) references post(id)
);
EOT
sqlite3 "$PEERNEWSDB"

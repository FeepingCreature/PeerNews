#!/bin/sh
rm peerlist.db
cat <<EOT |
create table peerlist (
  nick text not null,
  -- no sense having two peers at the same address
  -- insert or replace will delete previous entries with colliding unique constraints
  address text unique not null,
  pk text primary key,
  updated datetime not null default (datetime('now'))
);
EOT
sqlite3 peerlist.db 

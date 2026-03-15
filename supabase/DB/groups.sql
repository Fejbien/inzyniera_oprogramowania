create table groups (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references profiles(id) on delete restrict,
  name        text not null,
  description text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

create type group_role as enum ('owner', 'member');

create table group_members (
  id        uuid primary key default gen_random_uuid(),
  group_id  uuid not null references groups(id) on delete cascade,
  user_id   uuid not null references profiles(id) on delete cascade,
  role      group_role not null default 'member',
  joined_at timestamptz not null default now(),

  unique (group_id, user_id)
);

create index on group_members (user_id);
create index on group_members (group_id);
create type challenge_status as enum ('pending', 'active', 'finished');

create table challenges (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references groups(id) on delete cascade,
  created_by  uuid not null references profiles(id) on delete set null,
  name        text not null,
  status      challenge_status not null default 'pending',
  starts_at   timestamptz not null,
  ends_at     timestamptz,               -- null = trwa aż zostanie 1 osoba
  created_at  timestamptz not null default now()
);

create table challenge_participants (
  id              uuid primary key default gen_random_uuid(),
  challenge_id    uuid not null references challenges(id) on delete cascade,
  user_id         uuid not null references profiles(id) on delete cascade,
  total_steps     int not null default 0,
  is_eliminated   boolean not null default false,
  eliminated_at   timestamptz,
  joined_at       timestamptz not null default now(),

  unique (challenge_id, user_id)
);

create index on challenge_participants (challenge_id, is_eliminated);

-- Snapshoty kroków w czasie wyzwania (zbierane co godzinę, jak step_logs)
create table challenge_step_snapshots (
  id                uuid primary key default gen_random_uuid(),
  participant_id    uuid not null references challenge_participants(id) on delete cascade,
  steps_delta       int not null default 0,  -- przyrost w tej godzinie
  cumulative_steps  int not null default 0,  -- suma od startu wyzwania
  recorded_at       timestamptz not null default now()
);

create index on challenge_step_snapshots (participant_id, recorded_at desc);
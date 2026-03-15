create table step_logs (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  hour_start   timestamptz not null,  -- zawsze obcięte do pełnej godziny (date_trunc)
  steps_count  int not null check (steps_count >= 0),
  source       text not null default 'health_connect',
  synced_at    timestamptz not null default now(),

  unique (user_id, hour_start)
);

create index on step_logs (user_id, hour_start desc);
create index on step_logs (hour_start desc);  -- dla zapytań grupowych

-- Upsert z aplikacji mobilnej (wywoływane co godzinę)
-- insert into step_logs (user_id, hour_start, steps_count)
-- values ($1, date_trunc('hour', now()), $2)
-- on conflict (user_id, hour_start) do update set steps_count = excluded.steps_count, synced_at = now();
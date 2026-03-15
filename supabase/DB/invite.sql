create table group_invites (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references groups(id) on delete cascade,
  created_by  uuid not null references profiles(id) on delete cascade,
  token       text not null unique default encode(gen_random_bytes(12), 'hex'),
  max_uses    int,                          -- null = bez limitu
  uses_count  int not null default 0,
  expires_at  timestamptz,                  -- null = nigdy nie wygasa
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

create index on group_invites (token);

-- RPC: użytkownik klika link zaproszenia
create or replace function join_group_by_token(invite_token text)
returns json language plpgsql security definer as $$
declare
  v_invite  group_invites;
  v_user_id uuid := auth.uid();
begin
  select * into v_invite from group_invites
  where token = invite_token
    and is_active = true
    and (expires_at is null or expires_at > now())
    and (max_uses is null or uses_count < max_uses);

  if not found then
    return json_build_object('error', 'Zaproszenie nieważne lub wygasło');
  end if;

  insert into group_members (group_id, user_id)
  values (v_invite.group_id, v_user_id)
  on conflict (group_id, user_id) do nothing;

  update group_invites set uses_count = uses_count + 1 where id = v_invite.id;

  return json_build_object('group_id', v_invite.group_id);
end;
$$;
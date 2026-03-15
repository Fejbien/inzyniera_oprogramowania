alter table profiles                  enable row level security;
alter table step_logs                 enable row level security;
alter table groups                    enable row level security;
alter table group_members             enable row level security;
alter table group_invites             enable row level security;
alter table challenges                enable row level security;
alter table challenge_participants    enable row level security;
alter table challenge_step_snapshots  enable row level security;

-- Przykładowe polityki
create policy "własny profil" on profiles for all using (auth.uid() = id);

create policy "własne logi kroków" on step_logs for all using (auth.uid() = user_id);

create policy "logi kroków widoczne w grupie" on step_logs for select
  using (exists (
    select 1 from group_members gm1
    join  group_members gm2 on gm1.group_id = gm2.group_id
    where gm1.user_id = auth.uid() and gm2.user_id = step_logs.user_id
  ));

create policy "członkowie grupy widzą grupę" on groups for select
  using (exists (
    select 1 from group_members where group_id = groups.id and user_id = auth.uid()
  ));

create policy "twórca może modyfikować grupę" on groups for update
  using (owner_id = auth.uid());
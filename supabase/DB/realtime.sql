-- Włącz realtime na tabeli snapshotów
alter publication supabase_realtime add table challenge_step_snapshots;
alter publication supabase_realtime add table challenge_participants;
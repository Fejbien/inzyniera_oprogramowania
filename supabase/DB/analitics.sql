-- Statystyki kroków na dzień w miesiącu dla grupy
create or replace view group_daily_steps as
select
  gm.group_id,
  sl.user_id,
  p.display_name,
  date_trunc('day', sl.hour_start) as day,
  sum(sl.steps_count)              as daily_steps
from step_logs sl
join group_members gm on gm.user_id = sl.user_id
join profiles p on p.id = sl.user_id
group by gm.group_id, sl.user_id, p.display_name, date_trunc('day', sl.hour_start);

-- Statystyki godzinowe (do wykresu w profilu)
create or replace view user_hourly_steps as
select
  user_id,
  extract(hour from hour_start) as hour_of_day,
  extract(dow  from hour_start) as day_of_week,
  avg(steps_count)::int         as avg_steps,
  sum(steps_count)              as total_steps,
  count(*)                      as data_points
from step_logs
group by user_id, extract(hour from hour_start), extract(dow from hour_start);
create or replace function get_today_reservations_by_user(
  p_user_id uuid
)
returns table (
  id uuid,
  start timestamptz,
  "end" timestamptz,
  course_name text,
  room_name text,
  first_name text,
  last_name text
)
language plpgsql
as $$
begin
  return query
  select
    c.id,
    c.start,
    c.end,
    c.course_name,
    c.room as room_name,
    t.first_name,
    t.last_name
  from public.courses c
  join public.users s on s.proms_id = c.proms_id
  join public.users t on t.badge_id = c.instructor_id
  where s.badge_id = p_user_id
    and c.start >= date_trunc('day', now() at time zone 'Europe/Paris')
    and c.start <  date_trunc('day', now() at time zone 'Europe/Paris') + interval '1 day'
  order by c.start asc;
end;
$$;

## base

begin
  return query
  select
    r.id,
    r.start,
    r.ends,
    c.course_name,
    rm.name as room_name,
    u.first_name,
    u.last_name
  from public.users_reserves ur
  join public.reservation r on r.id = ur.reservation_id
  join public.courses c on c.reservation_id = r.id
  join public.rooms rm on rm.id = c.room_id
  join public.users u on u.badge_id = c.instructor_id
  where ur.user_id = p_user_id
    and r.start >= date_trunc('day', now() at time zone 'Europe/Paris')
    and r.start <  date_trunc('day', now() at time zone 'Europe/Paris') + interval '1 day'
  order by r.start asc;
end;
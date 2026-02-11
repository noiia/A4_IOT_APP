DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  SELECT 
    u.first_name || ' ' || u.last_name as student_name,
    u.avatar_url,
    c.course_name,
    EXTRACT(EPOCH FROM (p."Date" - c.start))/60::INT as late_minutes,
    p."Date" as pointing_time
  FROM pointing p
  JOIN users u ON u.badge_id = p.user_badge_id
  JOIN courses c ON c.proms_id = u.proms_id
  WHERE c.instructor_id = p_instructor_id
  AND c.start >= today_start
  AND c.start < today_end
  AND p."Date" > c.start + INTERVAL '15 minutes'
  AND p."Date" <= c.end
  AND u.status = 'student';
END;


## base 

DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  SELECT 
    u.first_name || ' ' || u.last_name as student_name,
    u.avatar_url,
    c.course_name,
    EXTRACT(EPOCH FROM (p."Date" - res.start))/60::INT as late_minutes,
    p."Date" as pointing_time
  FROM pointing p
  JOIN users u ON u.badge_id = p.user_badge_id
  JOIN users_reserves ur ON ur.user_id = p.user_badge_id
  JOIN reservation res ON res.id = ur.reservation_id
  JOIN courses c ON c.reservation_id = res.id
  WHERE c.instructor_id = p_instructor_id
  AND res.start >= today_start
  AND res.start < today_end
  AND p."Date" > res.start + INTERVAL '15 minutes'
  AND p."Date" <= res.ends
  AND u.status = 'student';
END;
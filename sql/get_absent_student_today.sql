
DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  SELECT 
    u.first_name || ' ' || u.last_name as student_name,
    u.avatar_url,
    c.course_name,
    c.start as course_start
  FROM users u 
  JOIN courses c ON c.proms_id = u.proms_id
  WHERE c.instructor_id = p_instructor_id
  AND c.start >= today_start
  AND c.start < today_end
  AND NOW() > c.start + INTERVAL '15 minutes'
  AND u.status = 'student'
  AND NOT EXISTS (
    SELECT 1 FROM pointing p 
    WHERE p.user_badge_id = u.badge_id 
    AND p."Date" >= c.start
    AND p."Date" <= c.end
  );
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
    res.start as course_start
  FROM users_reserves ur
  JOIN users u ON u.badge_id = ur.user_id
  JOIN reservation res ON res.id = ur.reservation_id
  JOIN courses c ON c.reservation_id = res.id
  WHERE c.instructor_id = p_instructor_id
  AND res.start >= today_start
  AND res.start < today_end
  AND NOW() > res.start + INTERVAL '15 minutes'
  AND u.status = 'student'
  AND NOT EXISTS (
    SELECT 1 FROM pointing p 
    WHERE p.user_badge_id = ur.user_id 
    AND p."Date" >= res.start
    AND p."Date" <= res.ends
  );
END;

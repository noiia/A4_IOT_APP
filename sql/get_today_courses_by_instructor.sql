
DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.course_name,
    c.instructor_id,
    c.room_id,
    c.room as room_name,
    '',
    c.start,
    c.end,
    (SELECT COUNT(*) FROM users u WHERE u.proms_id = c.proms_id) as expected_students,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users u ON u.badge_id = p.user_badge_id
     WHERE u.proms_id = c.proms_id 
     AND p."Date" >= c.start 
     AND p."Date" <= c.end) as present_students
  FROM courses c
  WHERE c.instructor_id = p_instructor_id
  AND c.start >= today_start
  AND c.start < today_end
  ORDER BY c.start ASC;
END;


## base 

DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.course_name,
    c.instructor_id,
    c.room_id,
    r.name as room_name,
    c.reservation_id,
    res.start,
    res.ends,
    (SELECT COUNT(*) FROM users_reserves ur WHERE ur.reservation_id = c.reservation_id) as expected_students,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users_reserves ur ON ur.user_id = p.user_badge_id
     WHERE ur.reservation_id = c.reservation_id 
     AND p."Date" >= res.start 
     AND p."Date" <= res.ends) as present_students
  FROM courses c
  JOIN rooms r ON r.id = c.room_id
  JOIN reservation res ON res.id = c.reservation_id
  WHERE c.instructor_id = p_instructor_id
  AND res.start >= today_start
  AND res.start < today_end
  ORDER BY res.start ASC;
END;

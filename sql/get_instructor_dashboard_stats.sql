DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  WITH course_reservations AS (
    SELECT DISTINCT c.id, c.proms_id, c.start, c.end
    FROM courses c
    WHERE c.instructor_id = p_instructor_id
    AND c.start >= today_start
    AND c.start < today_end
  ),
  enrolled_students AS (
    SELECT DISTINCT u.badge_id
    FROM users u
    JOIN course_reservations cr ON cr.proms_id = u.proms_id
    WHERE u.status = 'student'
  ),
  present_students AS (
    SELECT DISTINCT p.user_badge_id
    FROM pointing p
    JOIN enrolled_students es ON es.badge_id = p.user_badge_id
    JOIN course_reservations cr ON TRUE
    WHERE p."Date" >= cr.start - INTERVAL '1 hour'
    AND p."Date" <= cr.end
  ),
  late_students AS (
    SELECT DISTINCT p.user_badge_id
    FROM pointing p
    JOIN enrolled_students es ON es.badge_id = p.user_badge_id
    JOIN course_reservations cr ON TRUE
    WHERE p."Date" > cr.start + INTERVAL '15 minutes'
    AND p."Date" <= cr.end
  )
  SELECT 
    (SELECT COUNT(*) FROM enrolled_students) as total_students,
    (SELECT COUNT(*) FROM present_students) as present_today,
    (SELECT COUNT(*) FROM enrolled_students) - (SELECT COUNT(*) FROM present_students) as absent_today,
    (SELECT COUNT(*) FROM late_students) as late_today;
END;


## base 


DECLARE
  today_start TIMESTAMPTZ := DATE_TRUNC('day', NOW());
  today_end TIMESTAMPTZ := today_start + INTERVAL '1 day';
BEGIN
  RETURN QUERY
  WITH course_reservations AS (
    SELECT DISTINCT c.reservation_id, res.start, res.ends
    FROM courses c
    JOIN reservation res ON res.id = c.reservation_id
    WHERE c.instructor_id = p_instructor_id
    AND res.start >= today_start
    AND res.start < today_end
  ),
  enrolled_students AS (
    SELECT DISTINCT ur.user_id
    FROM users_reserves ur
    JOIN course_reservations cr ON cr.reservation_id = ur.reservation_id
    JOIN users u ON u.badge_id = ur.user_id
    WHERE u.status = 'student'
  ),
  present_students AS (
    SELECT DISTINCT p.user_badge_id
    FROM pointing p
    JOIN enrolled_students es ON es.user_id = p.user_badge_id
    JOIN course_reservations cr ON TRUE
    WHERE p."Date" >= cr.start - INTERVAL '1 hour'
    AND p."Date" <= cr.ends
  ),
  late_students AS (
    SELECT DISTINCT p.user_badge_id
    FROM pointing p
    JOIN enrolled_students es ON es.user_id = p.user_badge_id
    JOIN course_reservations cr ON TRUE
    WHERE p."Date" > cr.start + INTERVAL '15 minutes'
    AND p."Date" <= cr.ends
  )
  SELECT 
    (SELECT COUNT(*) FROM enrolled_students) as total_students,
    (SELECT COUNT(*) FROM present_students) as present_today,
    (SELECT COUNT(*) FROM enrolled_students) - (SELECT COUNT(*) FROM present_students) as absent_today,
    (SELECT COUNT(*) FROM late_students) as late_today;
END;
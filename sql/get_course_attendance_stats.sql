
DECLARE
  v_start TIMESTAMPTZ;
  v_end TIMESTAMPTZ;
  v_late_threshold TIMESTAMPTZ;
BEGIN
  -- Récupérer les horaires du cours
  SELECT c.start, c.end INTO v_start, v_end
  FROM courses c
  WHERE c.id = p_course_id;
  
  v_late_threshold := v_start + INTERVAL '15 minutes';
  
  RETURN QUERY
  SELECT 
    c.id as course_id,
    c.course_name,
    c.room as room_name,
    v_start as start_time,
    v_end as end_time,
    (SELECT COUNT(*) FROM users u 
     WHERE u.proms_id = p_proms_id 
     AND u.status = 'student') as total_expected,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users u ON u.badge_id = p.user_badge_id
     JOIN courses c ON c.proms_id = u.proms_id
     WHERE c.id = p_course_id 
     AND p."Date" <= v_late_threshold) as present_count,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users u ON us.badge_id = p.user_badge_id
     JOIN courses c ON c.proms_id = u.proms_id
     WHERE c.id = p_course_id 
     AND p."Date" > v_late_threshold
     AND p."Date" <= v_end) as late_count,
    (SELECT COUNT(*) FROM users u 
     JOIN courses c ON c.proms_id = u.proms_id
     WHERE c.id = p_course_id 
     AND u.status = 'student'
     AND NOT EXISTS (
       SELECT 1 FROM pointing p 
       WHERE p.user_badge_id = u.badge_id 
       AND p."Date" >= v_start - INTERVAL '1 hour'
       AND p."Date" <= v_end
     )) as absent_count

  FROM courses c
  JOIN rooms r ON r.id = c.room_id
  WHERE c.id = p_course_id;
END;

## base 

DECLARE
  v_start TIMESTAMPTZ;
  v_end TIMESTAMPTZ;
  v_late_threshold TIMESTAMPTZ;
BEGIN
  -- Récupérer les horaires du cours
  SELECT res.start, res.ends INTO v_start, v_end
  FROM reservation res
  WHERE res.id = p_reservation_id;
  
  v_late_threshold := v_start + INTERVAL '15 minutes';
  
  RETURN QUERY
  SELECT 
    c.id as course_id,
    c.course_name,
    r.name as room_name,
    v_start as start_time,
    v_end as end_time,
    (SELECT COUNT(*) FROM users_reserves ur 
     JOIN users u ON u.badge_id = ur.user_id 
     WHERE ur.reservation_id = p_reservation_id 
     AND u.status = 'student') as total_expected,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users_reserves ur ON ur.user_id = p.user_badge_id
     WHERE ur.reservation_id = p_reservation_id 
     AND p."Date" <= v_late_threshold) as present_count,
    (SELECT COUNT(DISTINCT p.user_badge_id) 
     FROM pointing p 
     JOIN users_reserves ur ON ur.user_id = p.user_badge_id
     WHERE ur.reservation_id = p_reservation_id 
     AND p."Date" > v_late_threshold
     AND p."Date" <= v_end) as late_count,
    (SELECT COUNT(*) FROM users_reserves ur 
     JOIN users u ON u.badge_id = ur.user_id 
     WHERE ur.reservation_id = p_reservation_id 
     AND u.status = 'student'
     AND NOT EXISTS (
       SELECT 1 FROM pointing p 
       WHERE p.user_badge_id = ur.user_id 
       AND p."Date" >= v_start - INTERVAL '1 hour'
       AND p."Date" <= v_end
     )) as absent_count
  FROM courses c
  JOIN rooms r ON r.id = c.room_id
  WHERE c.id = p_course_id;
END;

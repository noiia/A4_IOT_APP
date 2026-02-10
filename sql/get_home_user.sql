select
    u.auth_user_id,
    u.badge_id,
    u.first_name,
    u.last_name,
    u.status,
    u.avatar_url,
    p.name as proms_name,
    c.name as campus_name,
    lp.created_at as last_pointing
from users u
left join last_pointing lp
    on lp.user_badge_id = u.badge_id
left join proms p
    on p.id = u.proms_id
left join campus c
    on c.id = p.campus_id
where u.auth_user_id = uid
limit 1;
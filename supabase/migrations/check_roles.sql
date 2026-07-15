select u.email, p.role
from auth.users u
join public.profiles p on p.id = u.id
where u.email in ('admin@test.com', 'kasir@test.com');

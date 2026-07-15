-- One-off: promote the test admin account created via Dashboard → Authentication → Users.
-- Run manually in SQL Editor (not part of the automated schema migration chain).
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'admin@test.com');

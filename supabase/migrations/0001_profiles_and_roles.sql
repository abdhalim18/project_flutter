-- Phase 1: auth & role foundation (admin vs kasir)

create type user_role as enum ('admin', 'kasir');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  role user_role not null default 'kasir',
  store_id uuid,
  created_at timestamptz not null default now()
);

-- Every new auth.users row gets a matching profile row (default role: kasir).
-- Promote to admin manually afterwards: update public.profiles set role = 'admin' where id = '<user-uuid>';
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Helper used by RLS policies across tables to check the caller's role.
create function public.is_admin()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles enable row level security;

create policy "profiles: users can read own row"
  on public.profiles for select
  using (id = auth.uid());

create policy "profiles: admin can read all rows"
  on public.profiles for select
  using (public.is_admin());

create policy "profiles: admin can update any row"
  on public.profiles for update
  using (public.is_admin());

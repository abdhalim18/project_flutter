-- Phase 2: product & stock management (online-only for now; Drift mirror comes in Phase 3)

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories (id) on delete set null,
  name text not null,
  sku text,
  price numeric(12, 2) not null default 0,
  stock_qty integer not null default 0,
  photo_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_products_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

alter table public.categories enable row level security;
alter table public.products enable row level security;

-- Any authenticated user (admin or kasir) can browse the catalog.
create policy "categories: authenticated can read"
  on public.categories for select
  to authenticated
  using (true);

create policy "products: authenticated can read"
  on public.products for select
  to authenticated
  using (true);

-- Only admin can change the catalog; kasir writes are rejected at the DB level.
create policy "categories: admin can write"
  on public.categories for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "products: admin can write"
  on public.products for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Storage bucket for product photos: public read, admin-only write.
insert into storage.buckets (id, name, public)
values ('product-photos', 'product-photos', true)
on conflict (id) do nothing;

create policy "product-photos: public read"
  on storage.objects for select
  using (bucket_id = 'product-photos');

create policy "product-photos: admin write"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'product-photos' and public.is_admin());

create policy "product-photos: admin update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'product-photos' and public.is_admin());

create policy "product-photos: admin delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'product-photos' and public.is_admin());

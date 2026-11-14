-- ============================================================================
-- ISI DATABASE BARU NEON: struktur tabel + menu awal + akun admin, dalam satu file.
-- Cara pakai: buka Neon Console → SQL Editor, ganti v_password (dan email/nama) di bagian
-- "Akun admin" paling bawah, tempel seluruh file ini, lalu Run. Aman dijalankan ulang.
--
-- File ini gabungan db/schema.sql + db/seed.sql (dibuat ulang dengan: npm run db:init-sql).
-- ============================================================================

-- Skema database POS untuk Neon (Postgres biasa).
--
--   * Akun disimpan di tabel public.users (email + hash bcrypt).
--   * Aplikasi tidak terhubung langsung ke database: semua akses lewat API (src/index.ts),
--     dan aturan akses dicek di sana.
--   * Foto produk disimpan di tabel public.photos (bytea).
--   * Aplikasi memakai pull sync, tanpa realtime.
--
-- Aman dijalankan ulang: semua objek dibuat dengan "if not exists" / "or replace".

do $$ begin
  create type user_role as enum ('admin', 'kasir');
exception when duplicate_object then null;
end $$;

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  password_hash text not null,
  created_at timestamptz not null default now()
);
create unique index if not exists users_email_lower_key on public.users (lower(email));

create table if not exists public.profiles (
  id uuid primary key references public.users (id) on delete cascade,
  full_name text,
  role user_role not null default 'kasir',
  store_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories (id) on delete set null,
  name text not null,
  sku text,
  price numeric(12, 2) not null default 0,
  stock_qty integer not null default 0,
  photo_url text,
  is_active boolean not null default true,
  needs_review boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_products_updated_at on public.products;
create trigger set_products_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

create table if not exists public.transactions (
  id uuid primary key,                          -- UUID dari aplikasi (kunci idempotensi offline)
  cashier_id uuid not null references public.profiles (id),
  total_amount numeric(12, 2) not null,
  discount_amount numeric(12, 2) not null default 0,
  payment_method text not null,
  payment_received numeric(12, 2) not null default 0,
  change_amount numeric(12, 2) not null default 0,
  status text not null default 'completed',
  client_created_at timestamptz not null,
  synced_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.transaction_items (
  id uuid primary key,
  transaction_id uuid not null references public.transactions (id) on delete cascade,
  product_id uuid references public.products (id),
  product_name_snapshot text not null,
  unit_price numeric(12, 2) not null,
  qty integer not null,
  subtotal numeric(12, 2) not null
);

-- Buku besar stok, hanya bisa ditambah. Satu-satunya cara stok berubah saat penjualan.
create table if not exists public.stock_movements (
  id uuid primary key,
  product_id uuid not null references public.products (id),
  change_qty integer not null,
  reason text not null,                         -- 'sale' | 'restock' | 'adjustment'
  reference_id uuid,                            -- transaction_id bila reason = 'sale'
  created_at timestamptz not null default now()
);

-- Stok boleh negatif (dua kasir offline menjual unit terakhir); produknya ditandai
-- needs_review sampai admin mengonfirmasi.
create or replace function public.apply_stock_movement()
returns trigger
language plpgsql
as $$
begin
  update public.products
  set stock_qty = stock_qty + new.change_qty,
      needs_review = needs_review or (stock_qty + new.change_qty < 0)
  where id = new.product_id;
  return new;
end;
$$;

drop trigger if exists on_stock_movement_insert on public.stock_movements;
create trigger on_stock_movement_insert
  after insert on public.stock_movements
  for each row execute function public.apply_stock_movement();

-- Foto produk, disajikan lewat GET /api/photos/:id.
create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  content_type text not null,
  data bytea not null,
  size_bytes integer not null,
  created_at timestamptz not null default now()
);

create index if not exists transactions_client_created_at_idx on public.transactions (client_created_at);
create index if not exists transactions_cashier_id_idx on public.transactions (cashier_id);
create index if not exists transaction_items_transaction_id_idx on public.transaction_items (transaction_id);
create index if not exists stock_movements_product_id_idx on public.stock_movements (product_id);

-- Isi awal database POS: 3 kategori dan 14 produk menu kafe, plus satu akun admin.
-- Aman dijalankan ulang: baris yang sudah ada (berdasarkan nama/email) dilewati.

insert into public.categories (name)
select v.name
from (values ('Kopi'), ('Non-Kopi'), ('Snack')) as v(name)
where not exists (select 1 from public.categories c where c.name = v.name);

insert into public.products (category_id, name, sku, price, stock_qty, photo_url, is_active)
select c.id, v.name, v.sku, v.price, v.stock_qty, v.photo_url, true
from (
  values
    ('Kopi', 'Espresso', 'ESP01', 15000, 50, 'https://picsum.photos/seed/espresso-cafe/600/600'),
    ('Kopi', 'Americano', 'AME01', 18000, 50, 'https://picsum.photos/seed/americano-cafe/600/600'),
    ('Kopi', 'Kopi Susu Gula Aren', 'KSG01', 20000, 40, 'https://picsum.photos/seed/kopi-susu-aren/600/600'),
    ('Kopi', 'Cappuccino', 'CAP01', 22000, 40, 'https://picsum.photos/seed/cappuccino-cafe/600/600'),
    ('Kopi', 'Cafe Latte', 'LAT01', 22000, 40, 'https://picsum.photos/seed/cafe-latte/600/600'),
    ('Kopi', 'Mocha', 'MOC01', 24000, 30, 'https://picsum.photos/seed/mocha-cafe/600/600'),
    ('Non-Kopi', 'Matcha Latte', 'MAT01', 23000, 30, 'https://picsum.photos/seed/matcha-latte/600/600'),
    ('Non-Kopi', 'Chocolate', 'CHO01', 21000, 30, 'https://picsum.photos/seed/hot-chocolate/600/600'),
    ('Non-Kopi', 'Thai Tea', 'THA01', 19000, 30, 'https://picsum.photos/seed/thai-tea/600/600'),
    ('Non-Kopi', 'Lemon Tea', 'LEM01', 17000, 30, 'https://picsum.photos/seed/lemon-tea/600/600'),
    ('Snack', 'Croissant', 'CRO01', 18000, 20, 'https://picsum.photos/seed/croissant-snack/600/600'),
    ('Snack', 'Donut Coklat', 'DON01', 12000, 25, 'https://picsum.photos/seed/donut-snack/600/600'),
    ('Snack', 'Banana Bread', 'BAN01', 16000, 20, 'https://picsum.photos/seed/banana-bread/600/600'),
    ('Snack', 'French Fries', 'FRI01', 15000, 25, 'https://picsum.photos/seed/french-fries/600/600')
) as v(category_name, name, sku, price, stock_qty, photo_url)
join public.categories c on c.name = v.category_name
where not exists (select 1 from public.products p where p.name = v.name);

-- Akun admin. GANTI v_email, v_name, dan v_password di bawah sebelum menjalankan.
-- Password di-hash bcrypt oleh pgcrypto (format yang sama dengan bcryptjs di API), jadi bisa langsung
-- dipakai login di aplikasi. Bila email sudah ada, akun itu tidak diubah.
-- Untuk akun kasir, jalankan blok ini lagi dengan v_role := 'kasir', atau pakai
-- npm run user:create -- kasir@toko.com kasir "Nama Kasir".
create extension if not exists pgcrypto;

do $seed$
declare
  v_email    text := 'admin@toko.com';
  v_name     text := 'Admin Toko';
  v_password text := 'GANTI_PASSWORD_INI';
  v_role     user_role := 'admin';
  v_id       uuid;
begin
  if v_password = 'GANTI_PASSWORD_INI' or length(v_password) < 8 then
    raise exception 'Ganti v_password di bagian akun admin dulu (minimal 8 karakter). Menu sudah masuk; jalankan ulang setelah diganti.';
  end if;
  if exists (select 1 from public.users where lower(email) = lower(v_email)) then
    raise notice 'Akun % sudah ada, dilewati.', v_email;
    return;
  end if;
  insert into public.users (email, password_hash)
  values (lower(v_email), crypt(v_password, gen_salt('bf', 10)))
  returning id into v_id;
  insert into public.profiles (id, full_name, role) values (v_id, v_name, v_role);
  raise notice 'Akun % (%) dibuat.', v_email, v_role;
end $seed$;

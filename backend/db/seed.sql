-- Isi awal database POS, sama dengan seed di supabase/migrations (0007_seed_cafe_menu):
-- 3 kategori dan 14 produk menu kafe, plus satu akun admin.
-- Aman dijalankan ulang: baris yang sudah ada (berdasarkan nama/email) dilewati.
--
-- Ini hanya menu awal. Data yang ditambahkan di Supabase setelah itu (akun kasir, produk baru,
-- perubahan stok, transaksi, foto yang diupload) TIDAK ada di sini; untuk itu pakai
-- npm run db:export lalu npm run db:import.

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
-- Password di-hash bcrypt oleh pgcrypto (format yang sama dengan Supabase), jadi bisa langsung
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

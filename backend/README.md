# POS API

Backend untuk aplikasi POS Flutter di folder induk ([../](../README.md)), pengganti Supabase.
[Hono](https://hono.dev) yang berjalan di [Neon Functions](https://neon.com/docs/compute/functions/overview),
satu tempat dengan database Postgres-nya di [Neon](https://neon.com). Tidak perlu Vercel atau server lain.
Kode: [src/index.ts](src/index.ts) (semua endpoint) dan [src/lib/](src/lib/).

| Dulu (Supabase)                           | Sekarang                                             |
| ----------------------------------------- | ---------------------------------------------------- |
| Server Supabase                           | Neon Functions (slug `posapi`), region sama dengan database |
| Supabase Auth                             | `POST /api/auth/login`, token JWT (berlaku 30 hari)  |
| PostgREST + Row Level Security            | Endpoint REST, aturan akses dicek di setiap endpoint |
| Storage bucket `product-photos`           | Tabel `photos` (bytea), `GET /api/photos/:id`        |
| Trigger stok & `needs_review`             | Sama, di [db/schema.sql](db/schema.sql)              |

## Endpoint

| Method & path                 | Akses       | Keterangan                                                        |
| ----------------------------- | ----------- | ----------------------------------------------------------------- |
| `GET /api/health`             | publik      | Cek API dan database                                              |
| `POST /api/auth/login`        | publik      | `{email, password}` → `{token, user, profile}`                    |
| `GET /api/me`                 | login       | Profil dan peran user                                             |
| `GET /api/categories`         | login       | Semua kategori                                                    |
| `POST /api/categories`        | admin       | `{name}`                                                          |
| `DELETE /api/categories/:id`  | admin       | Produk di kategori itu jadi tanpa kategori                        |
| `GET /api/products`           | login       | Semua produk (termasuk nonaktif)                                  |
| `POST /api/products`          | admin       | Tambah produk                                                     |
| `PATCH /api/products/:id`     | admin       | Ubah sebagian kolom                                               |
| `DELETE /api/products/:id`    | admin       | Hapus; produk yang pernah terjual dinonaktifkan → `{deleted}`     |
| `POST /api/photos`            | admin       | Body = byte gambar, header `Content-Type: image/*`, maks. 4 MB    |
| `GET /api/photos/:id`         | publik      | Foto produk (cache selamanya)                                     |
| `POST /api/sync/transactions` | login       | Transaksi offline + item + pergerakan stok, idempoten             |
| `GET /api/reports/sales`      | admin       | `?from=&to=` (ISO 8601), penjualan semua kasir                    |

Request yang butuh login memakai header `Authorization: Bearer <token>`.
Error selalu berbentuk `{ "error": "pesan", "code": "kode" }`.

## Menjalankan

```bash
npm install
cp .env.example .env.local   # isi DATABASE_URL dan JWT_SECRET
npm run db:schema            # pasang tabel (aman diulang)
npm run dev                  # http://localhost:3000 (pakai database di DATABASE_URL)
npm run typecheck            # cek tipe TypeScript
```

Butuh Node.js 22.18 atau lebih baru (menjalankan file `.ts` langsung).

Membuat akun atau mengganti password/peran (password diminta lewat prompt):

```bash
npm run user:create -- kasir@toko.com kasir "Nama Kasir"
npm run user:create -- admin@toko.com admin "Nama Admin"
```

## Mengisi database Neon baru lewat SQL Editor

[db/neon-init.sql](db/neon-init.sql) berisi struktur tabel, menu awal (3 kategori, 14 produk,
sama dengan seed Supabase), dan satu akun admin. Buka Neon Console → SQL Editor, ganti
`v_email`, `v_name`, dan `v_password` di bagian "Akun admin" paling bawah, tempel seluruh isi
file, lalu Run. Aman dijalankan ulang. File ini dibuat dari `db/schema.sql` + `db/seed.sql`;
setelah mengubah salah satunya, jalankan `npm run db:init-sql`.

File ini hanya menu awal. Untuk data asli dari Supabase pakai langkah di bawah.

### Foto menu

Ke-14 produk menu awal punya ilustrasi sendiri di [db/menu-photos/](db/menu-photos/), digambar dari
kode di [menu-art/generate.mjs](menu-art/generate.mjs). Untuk memasangnya ke database (produk
dicocokkan berdasarkan nama):

```bash
npm run menu:photos            # tambahkan -- --dry-run untuk melihat rencananya dulu
```

Untuk mengubah gambarnya, edit `menu-art/generate.mjs`, jalankan `npm run menu:art` (butuh Google
Chrome untuk merender), lalu `npm run menu:photos` lagi.

## Pindah dari Supabase ke Neon (sekali saja)

Isi `DATABASE_URL` (Neon) dan `SUPABASE_DB_URL` (Supabase Dashboard → Connect → Session
pooler) di `.env.local`. Jika project Supabase sedang di-pause, aktifkan dulu (Restore) di
dashboard. Urutannya:

**1. Export dari Supabase** (hanya membaca, Supabase tidak berubah)

```bash
npm run db:export
```

Hasilnya satu file `exports/pos-export-<tanggal>.sql` berisi skema Neon dan semua data: akun
(password lama tetap berlaku), profil, kategori, produk, transaksi, item, pergerakan stok, dan
foto produk. File ini juga cadangan kalau suatu saat perlu dipulihkan, jadi simpan salinannya
di tempat aman (isinya data bisnis dan hash password, jangan dibagikan; folder `exports/` tidak
ikut di-commit).

**2. Import ke Neon**

```bash
npm run db:import -- exports/pos-export-<tanggal>.sql
```

Import berjalan dalam satu transaksi (masuk semua atau tidak sama sekali), lalu jumlah baris
dan total stok dicocokkan dengan isi file. Bila Neon sudah berisi data, import ditolak; tambah
`--replace` untuk mengosongkan Neon dan mengimport ulang. File yang sama juga bisa diimport
tanpa Node: `psql "<url neon>" -v ON_ERROR_STOP=1 -f exports/pos-export-<tanggal>.sql`.

**3. Pindahkan aplikasi:** deploy API ini ke Neon Functions (lihat di bawah), isi `API_BASE_URL` di
aplikasi Flutter, build APK baru, pasang di semua HP kasir, lalu login dan coba satu transaksi.
Transaksi offline yang belum terkirim tetap tersimpan di HP dan terkirim ke Neon setelah login.

**4. Hapus data di Supabase**

```bash
npm run supabase:wipe -- exports/pos-export-<tanggal>.sql        # cek saja, belum menghapus
npm run supabase:wipe -- exports/pos-export-<tanggal>.sql --yes  # hapus permanen
```

Script ini menolak menghapus bila ada satu saja akun, produk, transaksi, atau foto di Supabase
yang belum ada di Neon (misalnya transaksi yang masuk setelah export). Yang dihapus: semua akun
auth, isi tabel POS, dan file di bucket `product-photos`. Penghapusan file foto butuh
`SUPABASE_SERVICE_ROLE_KEY` di `.env.local` (Supabase → Settings → API Keys); tanpa itu,
kosongkan bucket lewat Dashboard → Storage.

Kalau project Supabase itu tidak dipakai untuk hal lain, alternatif yang lebih bersih adalah
menghapus project-nya (Dashboard → Project Settings → General → Delete project) setelah langkah
3 selesai. Semua data, foto, dan kuotanya ikut hilang.

## Deploy ke Neon Functions

Sekali saja, hubungkan folder ini ke project Neon (login lewat browser, lalu pilih project
dan branch `production`):

```bash
cd backend
npx neon login
npx neon link --no-env-pull
```

Setiap kali deploy:

```bash
npm run deploy
```

Perintah ini mem-bundle `src/index.ts` (esbuild), mengunggahnya sebagai function `posapi`
dengan `JWT_SECRET` dari `.env.local`, lalu menampilkan URL-nya. `DATABASE_URL` diisi otomatis
oleh Neon (pooled, branch yang di-link). Buka `<URL>/api/health`, harus muncul `{"ok":true}`,
lalu isi `API_BASE_URL=<URL>` (tanpa garis miring di akhir) di `.env` aplikasi Flutter.

Paket Free Neon mencakup 1 juta request per bulan per project. Mengganti `JWT_SECRET` membuat
semua user harus login ulang.

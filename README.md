# Kasir POS

Aplikasi kasir (point of sale) Android berbasis Flutter. Aplikasi ini offline-first: transaksi
tetap bisa dicatat tanpa sinyal, lalu dikirim ke server begitu online lagi.

Satu repo berisi dua bagian:

| Folder                          | Isi                                                             |
| ------------------------------- | --------------------------------------------------------------- |
| `lib/`, `android/`, `test/`, …  | Aplikasi Flutter (Riverpod, Drift/SQLite lokal, go_router)      |
| [`backend/`](backend/README.md) | API (Hono di Neon Functions) dan skema database Postgres (Neon) |

```
HP kasir (Flutter)  ──►  backend/ di Neon Functions  ──►  database Neon
```

## Fitur

- Login dengan dua peran: **admin** dan **kasir**.
- Layar kasir: pilih produk, keranjang, pembayaran, dan kembalian.
- Offline-first: transaksi disimpan di SQLite lokal dan disinkronkan otomatis. Kirim ulang aman,
  tidak ada data ganda dan stok tidak terpotong dua kali.
- Admin: kelola produk, kategori, foto produk, dan stok. Produk dengan stok minus ditandai untuk
  dicek.
- Laporan penjualan per periode untuk semua kasir.

## Menjalankan aplikasi

```bash
cp .env.example .env      # isi API_BASE_URL dengan URL backend
flutter pub get
flutter run               # atau: flutter build apk --release
```

Untuk mencoba dengan backend di laptop, jalankan `npm run dev` di folder `backend/`, lalu isi
`API_BASE_URL=http://10.0.2.2:3000` (alamat laptop dilihat dari emulator Android; hanya untuk
build debug).

## Backend

Menyiapkan database, membuat akun, menjalankan di laptop, dan deploy ke Neon Functions ada di
[backend/README.md](backend/README.md).

## Tes

```bash
flutter test
```

Tes integrasi ke backend sungguhan dilewati kecuali variabel lingkungannya diisi:

```bash
API_TEST_URL=http://localhost:3000 \
API_TEST_ADMIN_EMAIL=... API_TEST_ADMIN_PASSWORD=... \
API_TEST_KASIR_EMAIL=... API_TEST_KASIR_PASSWORD=... \
flutter test test/api_integration_test.dart
```

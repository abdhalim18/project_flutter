// Mengekspor seluruh data POS dari Supabase ke satu file .sql yang siap diimport ke Neon.
//
//   Sumber : SUPABASE_DB_URL  (Supabase Dashboard → Connect → Session pooler)
//   Hasil  : exports/pos-export-<tanggal>.sql
//
// Isi file: skema Neon (db/schema.sql) + semua data: akun (auth.users → users, hash bcrypt
// tetap berlaku), profiles, categories, products, transactions, transaction_items,
// stock_movements, dan foto dari bucket "product-photos" (disimpan di tabel photos).
// Semua id dipertahankan. Data Supabase hanya dibaca, tidak diubah.
//
// File ini sekaligus menjadi cadangan sebelum data Supabase dihapus, jadi simpan baik-baik.
// Isinya data bisnis dan hash password: jangan dibagikan atau di-commit (folder exports/
// sudah di-gitignore).
//
// Jalankan: npm run db:export
// Import  : npm run db:import -- exports/pos-export-<tanggal>.sql
//           atau: psql "<url neon>" -v ON_ERROR_STOP=1 -f exports/pos-export-<tanggal>.sql
import { randomBytes, randomUUID } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";

import { connect, describe } from "./pg-connect.mjs";
import { BUCKET, BUCKET_MARKER, DATA_TABLES, MANIFEST_PREFIX } from "./export-format.mjs";

const CHUNK = 500;

const source = await connect(process.env.SUPABASE_DB_URL, { verify: false });
console.log(`Sumber: ${describe(process.env.SUPABASE_DB_URL)}`);

try {
  // 1. Baca semua data.
  const data = {};
  const users = await source.query(
    `select id, email, encrypted_password, created_at
       from auth.users
      where email is not null
      order by created_at`,
  );
  data.users = users.rows.map((u) => ({
    id: u.id,
    email: u.email.toLowerCase(),
    // Akun tanpa password (mis. login OAuth) tetap dibuat agar relasinya utuh, tapi tidak bisa login.
    password_hash: u.encrypted_password || "!",
    created_at: u.created_at,
  }));
  for (const table of DATA_TABLES.slice(1)) {
    data[table] = (await source.query(`select * from public.${table}`)).rows;
  }

  // 2. Unduh foto dari bucket. Error jaringan/server membuat export gagal, karena setelah
  //    Supabase dihapus foto itu tidak bisa diambil lagi. Foto yang memang sudah tidak ada
  //    di bucket (404/400) dilewati dan photo_url-nya dikosongkan.
  const photos = [];
  const skipped = [];
  let supabaseUrl = null;
  for (const product of data.products) {
    if (!product.photo_url?.includes(BUCKET_MARKER)) continue;
    supabaseUrl ??= new URL(product.photo_url).origin;
    const res = await fetch(product.photo_url);
    if (res.status === 404 || res.status === 400) {
      skipped.push(product.name);
      product.photo_url = null;
      continue;
    }
    if (!res.ok) {
      throw new Error(`Foto produk "${product.name}" gagal diunduh (HTTP ${res.status}): ${product.photo_url}`);
    }
    const bytes = Buffer.from(await res.arrayBuffer());
    const contentType = (res.headers.get("content-type") ?? "image/jpeg").split(";")[0];
    const id = randomUUID();
    photos.push({ id, content_type: contentType, data: bytes });
    product.photo_url = `/api/photos/${id}`;
  }
  const storageObjects = (
    await source.query("select count(*)::int as n from storage.objects where bucket_id = $1", [BUCKET])
  ).rows[0].n;

  // 3. Tulis file .sql.
  const counts = Object.fromEntries(DATA_TABLES.map((t) => [t, data[t].length]));
  counts.photos = photos.length;
  const manifest = {
    format: 1,
    exported_at: new Date().toISOString(),
    source_host: describe(process.env.SUPABASE_DB_URL),
    supabase_url: supabaseUrl,
    counts,
    stock_total: data.products.reduce((sum, p) => sum + Number(p.stock_qty), 0),
    storage_objects: storageObjects,
  };

  // Tag dollar-quote acak, supaya isi data apa pun tidak bisa menutup string-nya.
  const tag = `$pos_${randomBytes(6).toString("hex")}$`;
  const json = (rows) => {
    const text = JSON.stringify(rows);
    if (text.includes(tag)) throw new Error("Tag dollar-quote bentrok dengan isi data; jalankan ulang.");
    return `${tag}${text}${tag}`;
  };

  const schema = await readFile(new URL("../db/schema.sql", import.meta.url), "utf8");
  const out = [];
  out.push(
    "-- Export data POS dari Supabase, siap diimport ke Neon (atau Postgres lain).",
    "-- Import: npm run db:import -- <file ini>",
    '--     atau: psql "<url neon>" -v ON_ERROR_STOP=1 -f <file ini>',
    "-- Berisi data bisnis dan hash password. Jangan dibagikan.",
    `${MANIFEST_PREFIX}${JSON.stringify(manifest)}`,
    "",
    "-- ===== Skema (aman dijalankan ulang) =====",
    schema.trim(),
    "",
    "-- ===== Data (satu transaksi: masuk semua atau tidak sama sekali) =====",
    "begin;",
    "-- @replace-hook",
    "do $guard$ begin",
    "  if exists (select 1 from public.users) or exists (select 1 from public.products) then",
    "    raise exception 'Database tujuan sudah berisi data. Import dibatalkan. Pakai npm run db:import -- <file> --replace untuk menimpanya.';",
    "  end if;",
    "end $guard$;",
    "",
  );

  const insertRows = (table) => {
    const rows = data[table];
    for (let i = 0; i < rows.length; i += CHUNK) {
      out.push(
        `insert into public.${table} select * from json_populate_recordset(null::public.${table}, ${json(rows.slice(i, i + CHUNK))});`,
      );
    }
  };

  insertRows("users");
  insertRows("profiles");
  insertRows("categories");
  for (const p of photos) {
    out.push(
      `insert into public.photos (id, content_type, data, size_bytes) values ('${p.id}', '${p.content_type.replace(/'/g, "''")}', decode('${p.data.toString("base64")}', 'base64'), ${p.data.length});`,
    );
  }
  insertRows("products");
  insertRows("transactions");
  insertRows("transaction_items");
  out.push("-- stock_qty produk sudah final; trigger dimatikan agar stok tidak terpotong dua kali.");
  out.push("alter table public.stock_movements disable trigger on_stock_movement_insert;");
  insertRows("stock_movements");
  out.push("alter table public.stock_movements enable trigger on_stock_movement_insert;");
  out.push("commit;", "");

  const stamp = manifest.exported_at.replace(/[-:]/g, "").replace("T", "-").slice(0, 15);
  const dir = new URL("../exports/", import.meta.url);
  await mkdir(dir, { recursive: true });
  const fileUrl = new URL(`pos-export-${stamp}.sql`, dir);
  await writeFile(fileUrl, out.join("\n"), { mode: 0o600 });

  console.log("\nTabel               Baris");
  for (const [table, n] of Object.entries(counts)) console.log(`${table.padEnd(18)} ${String(n).padStart(6)}`);
  console.log(`\nTotal stok: ${manifest.stock_total}`);
  if (skipped.length) {
    console.log(`\nPeringatan: foto ${skipped.join(", ")} sudah tidak ada di bucket Supabase; produknya diekspor tanpa foto.`);
  }
  console.log(`\nFile export: exports/pos-export-${stamp}.sql`);
  console.log(`Lanjut: npm run db:import -- exports/pos-export-${stamp}.sql`);
} catch (error) {
  console.error(`\nExport gagal, tidak ada file yang ditulis: ${error.message}`);
  process.exitCode = 1;
} finally {
  await source.end();
}

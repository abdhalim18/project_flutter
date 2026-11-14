// Menghapus data POS di Supabase SETELAH semuanya terbukti ada di Neon.
//
// Tanpa --yes script ini hanya memeriksa dan menampilkan apa yang akan dihapus (dry run).
//
//   npm run supabase:wipe -- exports/pos-export-<tanggal>.sql          (cek saja)
//   npm run supabase:wipe -- exports/pos-export-<tanggal>.sql --yes    (hapus)
//
// Yang dihapus:
//   * isi tabel public: stock_movements, transaction_items, transactions, products,
//     categories, profiles (struktur tabelnya tetap ada, hanya datanya yang kosong)
//   * semua akun di auth.users
//   * semua file di bucket "product-photos" (butuh SUPABASE_SERVICE_ROLE_KEY di .env.local;
//     tanpa itu, kosongkan bucket lewat Dashboard → Storage)
//
// Pengaman: script menolak menghapus bila ada satu saja baris Supabase (akun, produk,
// transaksi, dst.) yang id-nya tidak ditemukan di Neon, misalnya transaksi yang masuk ke
// Supabase setelah export dibuat.
import { connect, describe } from "./pg-connect.mjs";
import { BUCKET, BUCKET_MARKER, DATA_TABLES, readExport } from "./export-format.mjs";

const args = process.argv.slice(2);
const YES = args.includes("--yes");
const file = args.find((a) => !a.startsWith("--"));

function supabaseUrlFrom(manifest) {
  if (process.env.SUPABASE_URL) return process.env.SUPABASE_URL.replace(/\/+$/, "");
  if (manifest.supabase_url) return manifest.supabase_url;
  const u = new URL(process.env.SUPABASE_DB_URL);
  const ref = decodeURIComponent(u.username).split(".")[1] ?? u.hostname.match(/^db\.([^.]+)\.supabase\.co$/)?.[1];
  return ref ? `https://${ref}.supabase.co` : null;
}

let source;
let target;
try {
  const { manifest } = await readExport(file);
  source = await connect(process.env.SUPABASE_DB_URL, { verify: false });
  target = await connect(process.env.DATABASE_URL);
  console.log(`Supabase: ${describe(process.env.SUPABASE_DB_URL)}`);
  console.log(`Neon    : ${describe(process.env.DATABASE_URL)}`);
  console.log(`Export  : ${file} (${manifest.exported_at})\n`);

  // 1. Pastikan setiap baris Supabase sudah ada di Neon.
  const supabaseIds = {
    users: (await source.query("select id from auth.users where email is not null")).rows.map((r) => r.id),
  };
  for (const table of DATA_TABLES.slice(1)) {
    supabaseIds[table] = (await source.query(`select id from public.${table}`)).rows.map((r) => r.id);
  }
  const missing = [];
  console.log("Tabel              Supabase  sudah di Neon");
  for (const table of DATA_TABLES) {
    const ids = supabaseIds[table];
    const found = (
      await target.query(`select count(*)::int as n from public.${table} where id = any($1::uuid[])`, [ids])
    ).rows[0].n;
    if (found !== ids.length) missing.push(`${table}: ${ids.length - found} baris belum ada di Neon`);
    console.log(`${table.padEnd(18)} ${String(ids.length).padStart(8)} ${String(found).padStart(14)}${found === ids.length ? "" : "  <-- KURANG"}`);
  }

  // Foto: setiap produk yang di Supabase memakai foto yang masih ada di bucket harus punya foto
  // di tabel photos Neon. (Foto yang sudah hilang dari bucket memang tidak bisa diekspor.)
  const objects = (
    await source.query("select name from storage.objects where bucket_id = $1", [BUCKET])
  ).rows.map((r) => r.name);
  const objectSet = new Set(objects);
  const photoProducts = (
    await source.query("select id, photo_url from public.products where photo_url like $1", [`%${BUCKET_MARKER}%`])
  ).rows
    .filter((r) => objectSet.has(decodeURIComponent(r.photo_url.split(BUCKET_MARKER)[1].split("?")[0])))
    .map((r) => r.id);
  const photosInNeon = (
    await target.query(
      `select count(*)::int as n from public.products p
         join public.photos ph on p.photo_url = '/api/photos/' || ph.id
        where p.id = any($1::uuid[])`,
      [photoProducts],
    )
  ).rows[0].n;
  if (photosInNeon !== photoProducts.length) missing.push(`foto: ${photoProducts.length - photosInNeon} foto produk belum ada di Neon`);
  console.log(`${"foto produk".padEnd(18)} ${String(photoProducts.length).padStart(8)} ${String(photosInNeon).padStart(14)}`);

  const allUsers = (await source.query("select count(*)::int as n from auth.users")).rows[0].n;
  const last = (await source.query("select max(synced_at) as t from public.transactions")).rows[0].t;
  console.log(`\nFile di bucket ${BUCKET}: ${objects.length}`);
  console.log(`Transaksi terakhir masuk ke Supabase: ${last ? last.toISOString() : "-"}`);

  if (missing.length) {
    throw new Error(
      `Ada data Supabase yang belum ada di Neon, penghapusan dibatalkan:\n  - ${missing.join("\n  - ")}\n` +
        "Biasanya karena aplikasi versi lama masih dipakai setelah export. Selama aplikasi baru\n" +
        "belum mencatat apa pun di Neon: buat export baru (npm run db:export), import dengan\n" +
        "--replace, lalu ulangi. (Import --replace menolak sendiri bila Neon sudah berisi data baru.)",
    );
  }
  console.log("\nSemua data Supabase sudah ada di Neon.");

  if (!YES) {
    console.log(
      `\nDRY RUN, belum ada yang dihapus. Yang akan dihapus permanen dengan --yes:\n` +
        `  - ${allUsers} akun auth.users\n` +
        DATA_TABLES.slice(1).map((t) => `  - ${supabaseIds[t].length} baris ${t}`).join("\n") +
        `\n  - ${objects.length} file di bucket ${BUCKET}`,
    );
  } else {
    // 2. Hapus data tabel dan akun dalam satu transaksi.
    await source.query("begin");
    await source.query(
      `truncate public.stock_movements, public.transaction_items, public.transactions,
                public.products, public.categories, public.profiles`,
    );
    await source.query("delete from auth.users");
    await source.query("commit");
    console.log(`\nDihapus: ${allUsers} akun dan semua isi tabel POS di Supabase.`);

    // 3. Hapus file di bucket lewat Storage API (menghapus baris storage.objects lewat SQL
    //    tidak menghapus file aslinya, jadi kuota storage tidak berkurang).
    const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const base = supabaseUrlFrom(manifest);
    if (objects.length === 0) {
      console.log("Bucket foto sudah kosong.");
    } else if (!key || !base) {
      console.log(
        `\n${objects.length} file foto belum dihapus: SUPABASE_SERVICE_ROLE_KEY belum diisi.\n` +
          `Kosongkan lewat Supabase Dashboard → Storage → ${BUCKET} → pilih semua → Delete,\n` +
          "atau isi kuncinya (Settings → API Keys → service_role/secret) lalu jalankan ulang perintah ini.",
      );
    } else {
      let removed = 0;
      for (let i = 0; i < objects.length; i += 100) {
        const res = await fetch(`${base}/storage/v1/object/${BUCKET}`, {
          method: "DELETE",
          headers: { apikey: key, Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
          body: JSON.stringify({ prefixes: objects.slice(i, i + 100) }),
        });
        if (!res.ok) throw new Error(`Storage API menolak penghapusan foto (HTTP ${res.status}). Data tabel sudah terhapus; kosongkan bucket lewat Dashboard.`);
        removed += (await res.json()).length;
      }
      console.log(`Dihapus: ${removed} file foto dari bucket ${BUCKET}.`);
    }
  }
} catch (error) {
  await source?.query("rollback").catch(() => {});
  console.error(`\n${error.message}`);
  process.exitCode = 1;
} finally {
  await source?.end();
  await target?.end();
}

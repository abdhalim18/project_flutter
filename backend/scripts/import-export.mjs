// Mengimport file hasil `npm run db:export` ke Neon (DATABASE_URL), lalu mencocokkan
// jumlah baris dan total stok dengan isi file.
//
// Jalankan: npm run db:import -- exports/pos-export-<tanggal>.sql
//           npm run db:import -- exports/pos-export-<tanggal>.sql --replace
//             (--replace mengosongkan tabel Neon dulu, dalam transaksi yang sama)
import { connect, describe } from "./pg-connect.mjs";
import { DATA_TABLES, readExport } from "./export-format.mjs";

const args = process.argv.slice(2);
const REPLACE = args.includes("--replace");
const file = args.find((a) => !a.startsWith("--"));

const TRUNCATE = `truncate public.stock_movements, public.transaction_items, public.transactions,
         public.products, public.categories, public.profiles, public.users, public.photos;`;

let target;
try {
  const { sql, manifest } = await readExport(file);
  console.log(`File  : ${file} (diekspor ${manifest.exported_at} dari ${manifest.source_host})`);
  target = await connect(process.env.DATABASE_URL);
  console.log(`Tujuan: ${describe(process.env.DATABASE_URL)}\n`);

  // --replace tidak boleh menghapus data yang dibuat di Neon setelah export (mis. transaksi
  // dari aplikasi versi baru). Cek tabelnya dulu: pada Neon yang masih kosong, tabel belum ada.
  if (REPLACE) {
    const hasSchema = (await target.query("select to_regclass('public.transactions') is not null as ok")).rows[0].ok;
    const newer = hasSchema
      ? (
          await target.query(
            `select (select count(*) from public.transactions where synced_at > $1)
                  + (select count(*) from public.products where updated_at > $1)
                  + (select count(*) from public.categories where created_at > $1)
                  + (select count(*) from public.users where created_at > $1) as n`,
            [manifest.exported_at],
          )
        ).rows[0].n
      : 0;
    if (Number(newer) > 0) {
      throw new Error(
        `Neon berisi ${newer} data yang dibuat/diubah setelah file ini diekspor (${manifest.exported_at}). ` +
          "--replace akan menghapusnya, jadi dibatalkan.",
      );
    }
  }

  // File berisi begin/commit sendiri, jadi gagal di tengah = tidak ada yang berubah.
  await target.query(REPLACE ? sql.replace("-- @replace-hook", TRUNCATE) : sql);

  console.log("Tabel               File   Neon");
  let ok = true;
  for (const table of [...DATA_TABLES, "photos"]) {
    const n = (await target.query(`select count(*)::int as n from public.${table}`)).rows[0].n;
    const expected = manifest.counts[table];
    if (n !== expected) ok = false;
    console.log(`${table.padEnd(18)} ${String(expected).padStart(5)} ${String(n).padStart(6)}${n === expected ? "" : "  <-- BEDA"}`);
  }
  const stock = (await target.query("select coalesce(sum(stock_qty),0)::int as s from public.products")).rows[0].s;
  if (stock !== manifest.stock_total) ok = false;
  console.log(`\nTotal stok: file ${manifest.stock_total}, Neon ${stock}${stock === manifest.stock_total ? " (cocok)" : "  <-- BEDA"}`);
  console.log(ok ? "\nImport selesai, semua cocok." : "\nImport selesai tapi ada yang BEDA. Cek sebelum menghapus Supabase.");
  if (!ok) process.exitCode = 1;
} catch (error) {
  await target?.query("rollback").catch(() => {});
  console.error(`\nImport dibatalkan, data Neon tidak berubah: ${error.message}`);
  process.exitCode = 1;
} finally {
  await target?.end();
}

// Mengunggah ilustrasi menu (db/menu-photos/<nama-produk>.jpg) ke tabel photos di database
// (DATABASE_URL), lalu memasang photo_url produk yang namanya cocok.
//
//   npm run menu:photos              (pasang foto)
//   npm run menu:photos -- --dry-run (tampilkan rencananya saja)
//
// Nama file = nama produk huruf kecil, spasi jadi "-" (mis. "Kopi Susu Gula Aren" →
// kopi-susu-gula-aren.jpg). Foto lama yang tersimpan di tabel photos dihapus bila tidak dipakai
// produk lain; URL luar (mis. picsum.photos) dicetak di log supaya bisa dikembalikan.
import { readFileSync, readdirSync } from "node:fs";

import { connect, describe } from "./pg-connect.mjs";

const DRY_RUN = process.argv.includes("--dry-run");
const DIR = new URL("../db/menu-photos/", import.meta.url);
const slug = (name) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
const OWN_PHOTO = /^\/api\/photos\/([0-9a-f-]{36})$/i;

const files = new Map(
  readdirSync(DIR)
    .filter((f) => f.endsWith(".jpg"))
    .map((f) => [f.slice(0, -4), f]),
);

const client = await connect(process.env.DATABASE_URL);
console.log(`Database: ${describe(process.env.DATABASE_URL)}${DRY_RUN ? "  (dry run)" : ""}\n`);
try {
  const { rows: products } = await client.query("select id, name, photo_url from public.products order by name");
  const used = new Set();
  let changed = 0;

  for (const product of products) {
    const file = files.get(slug(product.name));
    if (!file) {
      console.log(`  -  ${product.name.padEnd(22)} tidak ada ilustrasinya, dilewati`);
      continue;
    }
    used.add(slug(product.name));
    if (DRY_RUN) {
      console.log(`  ~  ${product.name.padEnd(22)} ← ${file}  (sekarang: ${product.photo_url ?? "-"})`);
      continue;
    }

    const bytes = readFileSync(new URL(file, DIR));
    await client.query("begin");
    const { rows } = await client.query(
      "insert into public.photos (content_type, data, size_bytes) values ('image/jpeg', $1, $2) returning id",
      [bytes, bytes.length],
    );
    await client.query("update public.products set photo_url = $1 where id = $2", [`/api/photos/${rows[0].id}`, product.id]);
    const old = product.photo_url?.match(OWN_PHOTO)?.[1];
    if (old) {
      await client.query(
        "delete from public.photos where id = $1 and not exists (select 1 from public.products where photo_url = $2)",
        [old, product.photo_url],
      );
    }
    await client.query("commit");
    changed++;
    console.log(`  ✓  ${product.name.padEnd(22)} ← ${file}  (sebelumnya: ${product.photo_url ?? "-"})`);
  }

  const unused = [...files.keys()].filter((k) => !used.has(k));
  if (unused.length) console.log(`\nIlustrasi tanpa produk yang namanya cocok: ${unused.join(", ")}`);
  if (!DRY_RUN) console.log(`\n${changed} produk mendapat foto baru.`);
} catch (error) {
  await client.query("rollback").catch(() => {});
  console.error(`\nGagal: ${error.message}`);
  process.exitCode = 1;
} finally {
  await client.end();
}

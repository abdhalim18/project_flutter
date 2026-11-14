// Konstanta bersama untuk export, import, dan penghapusan data Supabase.
import { readFile } from "node:fs/promises";

export const BUCKET = "product-photos";
export const BUCKET_MARKER = `/storage/v1/object/public/${BUCKET}/`;

// Urutan aman untuk insert (induk lebih dulu). "users" berasal dari auth.users Supabase.
export const DATA_TABLES = [
  "users",
  "profiles",
  "categories",
  "products",
  "transactions",
  "transaction_items",
  "stock_movements",
];

export const MANIFEST_PREFIX = "-- manifest: ";

/** Membaca file export beserta manifest (jumlah baris, total stok) di kepalanya. */
export async function readExport(path) {
  if (!path) throw new Error("Sebutkan file export, mis. exports/pos-export-20261113-0930.sql");
  const sql = await readFile(path, "utf8");
  const line = sql.split("\n").find((l) => l.startsWith(MANIFEST_PREFIX));
  if (!line) throw new Error(`${path} bukan file hasil npm run db:export (manifest tidak ada).`);
  return { sql, manifest: JSON.parse(line.slice(MANIFEST_PREFIX.length)) };
}

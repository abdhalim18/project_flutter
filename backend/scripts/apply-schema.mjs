// Memasang db/schema.sql ke database di DATABASE_URL. Aman dijalankan berulang.
// Jalankan: npm run db:schema
import { readFile } from "node:fs/promises";

import { connect, describe } from "./pg-connect.mjs";

const sql = await readFile(new URL("../db/schema.sql", import.meta.url), "utf8");
const client = await connect(process.env.DATABASE_URL);
try {
  await client.query(sql);
  const { rows } = await client.query(
    "select table_name from information_schema.tables where table_schema = 'public' order by table_name",
  );
  console.log(`Skema terpasang di ${describe(process.env.DATABASE_URL)}`);
  console.log("Tabel:", rows.map((r) => r.table_name).join(", "));
} finally {
  await client.end();
}

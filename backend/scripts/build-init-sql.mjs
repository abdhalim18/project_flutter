// Menggabungkan db/schema.sql + db/seed.sql menjadi db/neon-init.sql (satu file untuk
// ditempel di Neon SQL Editor). Jalankan ulang setiap kali schema.sql atau seed.sql berubah.
// Jalankan: npm run db:init-sql
import { readFile, writeFile } from "node:fs/promises";

const read = (name) => readFile(new URL(`../db/${name}`, import.meta.url), "utf8");
const [init, schema, seed] = await Promise.all([read("neon-init.sql"), read("schema.sql"), read("seed.sql")]);
const header = init.slice(0, init.indexOf("-- Skema database POS"));
await writeFile(new URL("../db/neon-init.sql", import.meta.url), `${header}${schema}\n${seed}`);
console.log("db/neon-init.sql diperbarui.");

// Deploy API ke Neon Functions (slug "posapi"), lalu menampilkan URL-nya.
//
// Sebelumnya, sekali saja:  npx neon login   lalu   npx neon link --no-env-pull
// Jalankan: npm run deploy
//
// JWT_SECRET diambil dari .env.local dan dikirim sebagai env function. DATABASE_URL tidak
// perlu dikirim: Neon mengisinya otomatis dengan database branch yang di-link.
import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { fileURLToPath } from "node:url";

const SLUG = "posapi";
// fileURLToPath, bukan .pathname: path folder bisa berisi spasi (mis. "project coding").
const root = fileURLToPath(new URL("..", import.meta.url));
const neon = fileURLToPath(new URL("../node_modules/.bin/neon", import.meta.url));

if (!existsSync(new URL("../.neon", import.meta.url))) {
  console.error("Folder ini belum terhubung ke project Neon. Jalankan dulu: npx neon login  lalu  npx neon link --no-env-pull");
  process.exit(1);
}
const secret = process.env.JWT_SECRET ?? "";
if (secret.length < 32) {
  console.error("JWT_SECRET di .env.local kosong atau kurang dari 32 karakter.");
  process.exit(1);
}

// Error dari execFileSync memuat argumen perintah (termasuk JWT_SECRET), jadi jangan dicetak mentah.
try {
  execFileSync(neon, ["functions", "deploy", SLUG, "--src", "src/index.ts", "--runtime", "nodejs24", "--env", `JWT_SECRET=${secret}`], {
    cwd: root,
    stdio: "inherit",
  });
} catch (error) {
  console.error(`\nDeploy gagal (${error.status ?? error.code}). Lihat pesan dari neon di atas.`);
  process.exit(1);
}
const info = JSON.parse(execFileSync(neon, ["functions", "get", SLUG, "-o", "json"], { cwd: root, encoding: "utf8" }));
const url = String(info.invocation_url ?? info.url ?? "").replace(/\/+$/, "");
console.log(`\nURL API: ${url}`);
console.log(`Cek    : ${url}/api/health   (harus {"ok":true})`);
console.log(`Flutter: isi API_BASE_URL=${url} di file .env aplikasi`);

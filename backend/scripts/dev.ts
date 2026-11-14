// Menjalankan API di laptop (http://localhost:3000) memakai .env.local.
// Jalankan: npm run dev
import { serve } from "@hono/node-server";

import app from "../src/index.ts";

const port = Number(process.env.PORT ?? 3000);
serve({ fetch: app.fetch, port }, () => {
  console.log(`POS API berjalan di http://localhost:${port}  (cek: /api/health)`);
});

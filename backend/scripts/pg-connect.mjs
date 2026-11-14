import pg from "pg";

/**
 * Membuat koneksi pg dari connection string, dengan pengaturan SSL yang eksplisit.
 * Parameter sslmode/channel_binding di URL (bawaan Neon & Supabase) dibuang supaya
 * tidak menimpa pengaturan ini.
 *
 * verify=false hanya dipakai untuk Supabase saat migrasi: sertifikat database Supabase
 * ditandatangani CA milik Supabase sendiri yang tidak ada di daftar CA Node.js.
 */
export async function connect(url, { verify = true } = {}) {
  if (!url) throw new Error("Connection string kosong. Cek .env.local");
  const parsed = new URL(url);
  parsed.searchParams.delete("sslmode");
  parsed.searchParams.delete("channel_binding");
  const isLocal = ["localhost", "127.0.0.1"].includes(parsed.hostname);
  const client = new pg.Client({
    connectionString: parsed.toString(),
    ssl: isLocal ? undefined : { rejectUnauthorized: verify },
  });
  await client.connect();
  return client;
}

/** Host saja, untuk log (tanpa user/password). */
export function describe(url) {
  try {
    const u = new URL(url);
    return `${u.hostname}${u.pathname}`;
  } catch {
    return "(url tidak valid)";
  }
}

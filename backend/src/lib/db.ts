import { Pool, types, type PoolClient } from "pg";

// numeric(12,2) dikembalikan pg sebagai string; aplikasi Flutter membacanya sebagai num.
types.setTypeParser(types.builtins.NUMERIC, (value) => Number.parseFloat(value));

function createPool() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) throw new Error("DATABASE_URL belum diisi di .env.local");
  // sslmode/channel_binding di URL Neon dibuang; SSL diatur eksplisit di bawah.
  const url = new URL(connectionString);
  url.searchParams.delete("sslmode");
  url.searchParams.delete("channel_binding");
  const isLocal = ["localhost", "127.0.0.1"].includes(url.hostname);
  return new Pool({
    connectionString: url.toString(),
    ssl: isLocal ? undefined : { rejectUnauthorized: true },
    max: 5,
    idleTimeoutMillis: 10_000,
  });
}

// Satu pool per proses (hot reload di dev tidak membuat pool baru setiap kali).
const globalForDb = globalThis as unknown as { posPool?: Pool };

export function db(): Pool {
  globalForDb.posPool ??= createPool();
  return globalForDb.posPool;
}

export async function withTransaction<T>(fn: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await db().connect();
  try {
    await client.query("begin");
    const result = await fn(client);
    await client.query("commit");
    return result;
  } catch (error) {
    await client.query("rollback").catch(() => {});
    throw error;
  } finally {
    client.release();
  }
}

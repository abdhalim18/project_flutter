// POS API untuk Neon Functions (Hono). Titik masuk yang di-deploy: export default app.
//
// Endpoint dan bentuk respons sama persis dengan versi Next.js sebelumnya, jadi aplikasi
// Flutter cukup mengganti API_BASE_URL.
import { attachDatabasePool } from "@neon/functions";
import bcrypt from "bcryptjs";
import { Hono } from "hono";

import { requireUser, signToken } from "./lib/auth.ts";
import { db, withTransaction } from "./lib/db.ts";
import { HttpError, errorResponse, isUuid, readJson, requireUuid } from "./lib/http.ts";
import { publicOrigin } from "./lib/photos.ts";
import { PRODUCT_COLUMNS, parseProductInput, presentProduct } from "./lib/products.ts";

type Row = Record<string, unknown>;

const app = new Hono();

// Koneksi idle yang diputus Neon tidak boleh membuat proses crash.
attachDatabasePool(db());

app.onError((error) => errorResponse(error));
app.notFound(() => Response.json({ error: "Endpoint tidak ditemukan", code: "not_found" }, { status: 404 }));

// ---------------------------------------------------------------------------------------
// Kesehatan & akun
// ---------------------------------------------------------------------------------------

/** Dipakai layar "Cek Koneksi Server" di aplikasi: membuktikan API dan database bisa dijangkau. */
app.get("/api/health", async () => {
  await db().query("select 1");
  return Response.json({ ok: true });
});

const INVALID_LOGIN = () => new HttpError(401, "Email atau password salah", "invalid_credentials");

// Hash palsu agar waktu respons sama saat email tidak terdaftar (tidak membocorkan email mana yang ada).
const DUMMY_HASH = bcrypt.hashSync("hash-pembanding-tidak-dipakai", 10);

app.post("/api/auth/login", async (c) => {
  const body = await readJson<{ email?: unknown; password?: unknown }>(c.req.raw);
  const email = typeof body.email === "string" ? body.email.trim().toLowerCase() : "";
  const password = typeof body.password === "string" ? body.password : "";
  if (!email || !password) throw new HttpError(400, "Email dan password wajib diisi", "invalid_input");

  const { rows } = await db().query<{
    id: string;
    email: string;
    password_hash: string;
    full_name: string | null;
    role: string;
    store_id: string | null;
  }>(
    `select u.id, u.email, u.password_hash, p.full_name, p.role, p.store_id
       from public.users u join public.profiles p on p.id = u.id
      where lower(u.email) = $1`,
    [email],
  );
  const user = rows[0];
  const hash = user?.password_hash?.startsWith("$2") ? user.password_hash : DUMMY_HASH;
  const ok = await bcrypt.compare(password, hash);
  if (!user || !ok || hash === DUMMY_HASH) throw INVALID_LOGIN();

  const token = await signToken(user);
  return Response.json({
    token,
    user: { id: user.id, email: user.email },
    profile: { id: user.id, full_name: user.full_name, role: user.role, store_id: user.store_id },
  });
});

/** Profil user yang sedang login. */
app.get("/api/me", async (c) => {
  const user = await requireUser(c.req.raw);
  const { rows } = await db().query("select id, full_name, role, store_id from public.profiles where id = $1", [
    user.id,
  ]);
  return Response.json({ user: { id: user.id, email: user.email }, profile: rows[0] });
});

// ---------------------------------------------------------------------------------------
// Kategori
// ---------------------------------------------------------------------------------------

app.get("/api/categories", async (c) => {
  await requireUser(c.req.raw);
  const { rows } = await db().query("select id, name, created_at from public.categories order by name");
  return Response.json(rows);
});

app.post("/api/categories", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const body = await readJson<{ name?: unknown }>(c.req.raw);
  const name = typeof body.name === "string" ? body.name.trim() : "";
  if (!name) throw new HttpError(400, "Nama kategori wajib diisi", "invalid_input");

  const { rows } = await db().query(
    "insert into public.categories (name) values ($1) returning id, name, created_at",
    [name],
  );
  return Response.json(rows[0], { status: 201 });
});

// Produk di kategori ini tidak ikut terhapus: category_id-nya menjadi null (on delete set null).
app.delete("/api/categories/:id", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const id = requireUuid(c.req.param("id"), "id");
  await db().query("delete from public.categories where id = $1", [id]);
  return new Response(null, { status: 204 });
});

// ---------------------------------------------------------------------------------------
// Produk
// ---------------------------------------------------------------------------------------

/** Semua produk, termasuk yang nonaktif (admin perlu melihatnya; layar kasir menyaringnya sendiri). */
app.get("/api/products", async (c) => {
  await requireUser(c.req.raw);
  const { rows } = await db().query(`select ${PRODUCT_COLUMNS} from public.products order by name`);
  return Response.json(rows.map((row) => presentProduct(row, c.req.raw)));
});

app.post("/api/products", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const input = parseProductInput(await readJson(c.req.raw), c.req.raw, false);
  const columns = Object.keys(input);
  const { rows } = await db().query(
    `insert into public.products (${columns.join(", ")})
     values (${columns.map((_, i) => `$${i + 1}`).join(", ")})
     returning ${PRODUCT_COLUMNS}`,
    Object.values(input),
  );
  return Response.json(presentProduct(rows[0], c.req.raw), { status: 201 });
});

app.patch("/api/products/:id", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const id = requireUuid(c.req.param("id"), "id");
  const input = parseProductInput(await readJson(c.req.raw), c.req.raw, true);
  const columns = Object.keys(input);
  if (columns.length === 0) throw new HttpError(400, "Tidak ada kolom yang diubah", "invalid_input");

  const { rows } = await db().query(
    `update public.products
        set ${columns.map((col, i) => `${col} = $${i + 2}`).join(", ")}
      where id = $1
      returning ${PRODUCT_COLUMNS}`,
    [id, ...Object.values(input)],
  );
  if (!rows[0]) throw new HttpError(404, "Produk tidak ditemukan", "not_found");
  return Response.json(presentProduct(rows[0], c.req.raw));
});

/**
 * Hapus permanen bila bisa. Produk yang pernah terjual punya baris di stock_movements
 * (buku besar stok sengaja tidak bisa dihapus), jadi penghapusannya ditolak foreign key;
 * dalam kasus itu produk dinonaktifkan saja. Respons {deleted} memberi tahu mana yang terjadi.
 */
app.delete("/api/products/:id", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const id = requireUuid(c.req.param("id"), "id");
  try {
    const result = await db().query("delete from public.products where id = $1", [id]);
    if (result.rowCount === 0) throw new HttpError(404, "Produk tidak ditemukan", "not_found");
    return Response.json({ deleted: true });
  } catch (error) {
    if ((error as { code?: string }).code !== "23503") throw error;
    await db().query("update public.products set is_active = false where id = $1", [id]);
    return Response.json({ deleted: false });
  }
});

// ---------------------------------------------------------------------------------------
// Foto (pengganti bucket Supabase "product-photos")
// ---------------------------------------------------------------------------------------

const MAX_PHOTO_BYTES = 4 * 1024 * 1024;
const PHOTO_TYPES = new Set(["image/jpeg", "image/png", "image/webp", "image/gif", "image/heic"]);

/** Body berisi byte gambar mentah dengan header Content-Type gambar. Respons {url} untuk photo_url. */
app.post("/api/photos", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const contentType = (c.req.header("content-type") ?? "").split(";")[0].trim().toLowerCase();
  if (!PHOTO_TYPES.has(contentType)) {
    throw new HttpError(415, "Format foto harus JPEG, PNG, WebP, GIF, atau HEIC", "unsupported_type");
  }

  const bytes = Buffer.from(await c.req.raw.arrayBuffer());
  if (bytes.length === 0) throw new HttpError(400, "File foto kosong", "invalid_input");
  if (bytes.length > MAX_PHOTO_BYTES) throw new HttpError(413, "Ukuran foto maksimal 4 MB", "too_large");

  const { rows } = await db().query<{ id: string }>(
    "insert into public.photos (content_type, data, size_bytes) values ($1, $2, $3) returning id",
    [contentType, bytes, bytes.length],
  );
  const path = `/api/photos/${rows[0].id}`;
  return Response.json({ id: rows[0].id, path, url: `${publicOrigin(c.req.raw)}${path}` }, { status: 201 });
});

/**
 * Publik (seperti bucket Supabase yang public), karena CachedNetworkImage di aplikasi tidak
 * mengirim token. Isi foto per id tidak pernah berubah, jadi aman di-cache selamanya.
 */
app.get("/api/photos/:id", async (c) => {
  const id = c.req.param("id");
  if (!isUuid(id)) throw new HttpError(404, "Foto tidak ditemukan", "not_found");

  const { rows } = await db().query<{ content_type: string; data: Buffer }>(
    "select content_type, data from public.photos where id = $1",
    [id],
  );
  const photo = rows[0];
  if (!photo) throw new HttpError(404, "Foto tidak ditemukan", "not_found");

  return new Response(new Uint8Array(photo.data), {
    headers: {
      "Content-Type": photo.content_type,
      "Content-Length": String(photo.data.length),
      "Cache-Control": "public, max-age=31536000, immutable",
    },
  });
});

// ---------------------------------------------------------------------------------------
// Sync transaksi offline
// ---------------------------------------------------------------------------------------

/**
 * Menerima satu transaksi offline beserta item dan pergerakan stoknya, dalam satu
 * transaksi database (semua masuk atau tidak sama sekali).
 *
 * Idempoten: semua baris memakai UUID dari aplikasi dan "on conflict do nothing", jadi
 * retry setelah koneksi putus tidak membuat data ganda dan stok tidak terpotong dua kali
 * (trigger stok hanya jalan untuk baris yang benar-benar baru masuk).
 *
 * Aturan akses sama dengan policy RLS di Supabase dulu:
 *   - kasir hanya boleh mengirim transaksi atas namanya sendiri;
 *   - item harus milik transaksi itu;
 *   - pergerakan stok dari kasir harus berupa 'sale' untuk transaksi itu (admin bebas).
 */
app.post("/api/sync/transactions", async (c) => {
  const user = await requireUser(c.req.raw);
  const body = await readJson<{ transaction?: Row; items?: unknown; movements?: unknown }>(c.req.raw);

  const tx = body.transaction;
  if (!tx || typeof tx !== "object") throw new HttpError(400, "transaction wajib diisi", "invalid_input");
  const txId = requireUuid(tx.id, "transaction.id");
  if (tx.cashier_id !== user.id) {
    throw new HttpError(403, "Transaksi hanya boleh dikirim oleh kasir yang membuatnya", "forbidden");
  }

  const items = Array.isArray(body.items) ? (body.items as Row[]) : [];
  const movements = Array.isArray(body.movements) ? (body.movements as Row[]) : [];

  for (const item of items) {
    requireUuid(item.id, "item.id");
    if (item.transaction_id !== txId) throw new HttpError(400, "Item bukan milik transaksi ini", "invalid_input");
  }
  for (const m of movements) {
    requireUuid(m.id, "movement.id");
    requireUuid(m.product_id, "movement.product_id");
    if (user.role !== "admin" && (m.reason !== "sale" || m.reference_id !== txId)) {
      throw new HttpError(403, "Pergerakan stok tidak diizinkan", "forbidden");
    }
  }

  const inserted = await withTransaction(async (client) => {
    const txResult = await client.query(
      `insert into public.transactions
         (id, cashier_id, total_amount, discount_amount, payment_method,
          payment_received, change_amount, status, client_created_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       on conflict (id) do nothing`,
      [
        txId,
        user.id,
        tx.total_amount,
        tx.discount_amount ?? 0,
        tx.payment_method,
        tx.payment_received ?? 0,
        tx.change_amount ?? 0,
        tx.status ?? "completed",
        tx.client_created_at,
      ],
    );

    // Id yang sudah ada harus milik kasir yang sama; kalau bukan, tolak (jangan menempel ke transaksi orang lain).
    const owner = await client.query<{ cashier_id: string }>(
      "select cashier_id from public.transactions where id = $1",
      [txId],
    );
    if (owner.rows[0]?.cashier_id !== user.id) {
      throw new HttpError(403, "Id transaksi sudah dipakai kasir lain", "forbidden");
    }

    let itemCount = 0;
    for (const item of items) {
      const r = await client.query(
        `insert into public.transaction_items
           (id, transaction_id, product_id, product_name_snapshot, unit_price, qty, subtotal)
         values ($1, $2, $3, $4, $5, $6, $7)
         on conflict (id) do nothing`,
        [item.id, txId, item.product_id ?? null, item.product_name_snapshot, item.unit_price, item.qty, item.subtotal],
      );
      itemCount += r.rowCount ?? 0;
    }

    let movementCount = 0;
    for (const m of movements) {
      const r = await client.query(
        `insert into public.stock_movements (id, product_id, change_qty, reason, reference_id, created_at)
         values ($1, $2, $3, $4, $5, coalesce($6::timestamptz, now()))
         on conflict (id) do nothing`,
        [m.id, m.product_id, m.change_qty, m.reason, m.reference_id ?? null, m.created_at ?? null],
      );
      movementCount += r.rowCount ?? 0;
    }

    return { transaction: txResult.rowCount ?? 0, items: itemCount, movements: movementCount };
  });

  return Response.json({ ok: true, inserted });
});

// ---------------------------------------------------------------------------------------
// Laporan
// ---------------------------------------------------------------------------------------

/**
 * Laporan penjualan semua kasir untuk admin, rentang [from, to).
 * Bentuk tiap baris sama dengan query PostgREST lama di aplikasi:
 *   { cashier_id, total_amount, client_created_at,
 *     cashier: { full_name }, transaction_items: [{ product_name_snapshot, qty, subtotal }] }
 */
app.get("/api/reports/sales", async (c) => {
  await requireUser(c.req.raw, { admin: true });
  const from = new Date(c.req.query("from") ?? "");
  const to = new Date(c.req.query("to") ?? "");
  if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
    throw new HttpError(400, "Parameter from dan to harus tanggal ISO 8601", "invalid_input");
  }

  const { rows } = await db().query(
    `select t.cashier_id,
            t.total_amount,
            t.client_created_at,
            json_build_object('full_name', p.full_name) as cashier,
            coalesce(
              json_agg(
                json_build_object(
                  'product_name_snapshot', i.product_name_snapshot,
                  'qty', i.qty,
                  'subtotal', i.subtotal::float8
                )
              ) filter (where i.id is not null),
              '[]'::json
            ) as transaction_items
       from public.transactions t
       left join public.profiles p on p.id = t.cashier_id
       left join public.transaction_items i on i.transaction_id = t.id
      where t.client_created_at >= $1 and t.client_created_at < $2
      group by t.id, p.full_name
      order by t.client_created_at`,
    [from.toISOString(), to.toISOString()],
  );
  return Response.json(rows);
});

export default app;

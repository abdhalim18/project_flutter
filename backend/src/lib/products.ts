import { HttpError, isUuid } from "./http.ts";
import { toPublicPhotoUrl, toStoredPhotoUrl } from "./photos.ts";

export const PRODUCT_COLUMNS =
  "id, category_id, name, sku, price, stock_qty, photo_url, is_active, needs_review, created_at, updated_at";

type ProductRow = { photo_url: string | null } & Record<string, unknown>;

export function presentProduct(row: ProductRow, request: Request) {
  return { ...row, photo_url: toPublicPhotoUrl(row.photo_url, request) };
}

/**
 * Mengambil kolom produk yang boleh diubah dari body request, dengan validasi tipe.
 * `partial` dipakai PATCH: kolom yang tidak dikirim tidak disentuh.
 */
export function parseProductInput(body: Record<string, unknown>, request: Request, partial: boolean) {
  const out: Record<string, unknown> = {};
  const has = (key: string) => Object.prototype.hasOwnProperty.call(body, key);

  if (has("name") || !partial) {
    const name = typeof body.name === "string" ? body.name.trim() : "";
    if (!name) throw new HttpError(400, "Nama produk wajib diisi", "invalid_input");
    out.name = name;
  }
  if (has("price") || !partial) {
    const price = Number(body.price ?? 0);
    if (!Number.isFinite(price) || price < 0) throw new HttpError(400, "Harga tidak valid", "invalid_input");
    out.price = price;
  }
  if (has("stock_qty") || !partial) {
    const qty = Number(body.stock_qty ?? 0);
    if (!Number.isInteger(qty)) throw new HttpError(400, "Stok harus bilangan bulat", "invalid_input");
    out.stock_qty = qty;
  }
  if (has("is_active")) {
    if (typeof body.is_active !== "boolean") throw new HttpError(400, "is_active harus boolean", "invalid_input");
    out.is_active = body.is_active;
  }
  if (has("needs_review")) {
    if (typeof body.needs_review !== "boolean") throw new HttpError(400, "needs_review harus boolean", "invalid_input");
    out.needs_review = body.needs_review;
  }
  if (has("category_id")) {
    if (body.category_id !== null && !isUuid(body.category_id)) {
      throw new HttpError(400, "category_id tidak valid", "invalid_input");
    }
    out.category_id = body.category_id;
  }
  if (has("sku")) {
    out.sku = typeof body.sku === "string" && body.sku.trim() ? body.sku.trim() : null;
  }
  if (has("photo_url")) {
    out.photo_url = toStoredPhotoUrl(body.photo_url, request);
  }
  return out;
}

// Foto yang disimpan di tabel photos dicatat di products.photo_url sebagai path relatif
// ("/api/photos/<id>"), supaya data tidak terikat ke domain deploy. Saat dikirim ke
// aplikasi, path itu diubah jadi URL lengkap memakai origin request. URL luar (mis.
// picsum.photos di menu contoh) disimpan dan dikirim apa adanya.

const PHOTO_PATH_RE = /\/api\/photos\/[0-9a-f-]{36}$/i;

export function toPublicPhotoUrl(stored: string | null, request: Request): string | null {
  if (!stored) return null;
  if (stored.startsWith("/")) return new URL(stored, publicOrigin(request)).toString();
  return stored;
}

export function toStoredPhotoUrl(value: unknown, request: Request): string | null {
  if (value === null || value === undefined || value === "") return null;
  if (typeof value !== "string") return null;
  const origin = publicOrigin(request);
  if (value.startsWith(origin) && PHOTO_PATH_RE.test(value)) return value.slice(origin.length);
  return value;
}

/** Origin publik server. Di belakang proxy memakai header x-forwarded-*. */
export function publicOrigin(request: Request): string {
  const host = request.headers.get("x-forwarded-host") ?? request.headers.get("host");
  const proto = request.headers.get("x-forwarded-proto") ?? new URL(request.url).protocol.replace(":", "");
  return host ? `${proto}://${host}` : new URL(request.url).origin;
}

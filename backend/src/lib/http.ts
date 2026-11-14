export class HttpError extends Error {
  readonly status: number;
  readonly code?: string;

  constructor(status: number, message: string, code?: string) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function isUuid(value: unknown): value is string {
  return typeof value === "string" && UUID_RE.test(value);
}

export function requireUuid(value: unknown, field: string): string {
  if (!isUuid(value)) throw new HttpError(400, `${field} harus UUID`, "invalid_input");
  return value;
}

export async function readJson<T = Record<string, unknown>>(request: Request): Promise<T> {
  try {
    const body = await request.json();
    if (body === null || typeof body !== "object") throw new Error();
    return body as T;
  } catch {
    throw new HttpError(400, "Body harus JSON object", "invalid_json");
  }
}

/** Kode error Postgres yang aman diteruskan ke aplikasi dengan status yang sesuai. */
const PG_ERRORS: Record<string, [number, string]> = {
  "23503": [409, "Data masih dipakai atau referensinya tidak ada"],
  "23505": [409, "Data sudah ada"],
  "23502": [400, "Ada kolom wajib yang kosong"],
  "22P02": [400, "Format data tidak valid"],
  "22003": [400, "Angka di luar batas"],
};

/** Mengubah error apa pun jadi respons JSON {error, code}: HttpError dan error Postgres yang dikenal. */
export function errorResponse(error: unknown): Response {
  if (error instanceof HttpError) {
    return Response.json({ error: error.message, code: error.code }, { status: error.status });
  }
  const pgCode = (error as { code?: unknown })?.code;
  if (typeof pgCode === "string" && PG_ERRORS[pgCode]) {
    const [status, message] = PG_ERRORS[pgCode];
    return Response.json({ error: message, code: pgCode }, { status });
  }
  console.error(error);
  return Response.json({ error: "Terjadi kesalahan di server", code: "internal" }, { status: 500 });
}

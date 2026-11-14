import { SignJWT, jwtVerify } from "jose";

import { db } from "./db.ts";
import { HttpError } from "./http.ts";

export type Role = "admin" | "kasir";

export type AuthUser = { id: string; email: string; role: Role };

// Token berlaku lama karena aplikasi dirancang offline-first: kasir bisa berhari-hari
// tanpa sinyal dan tetap harus bisa sync begitu online lagi.
const TOKEN_TTL = "30d";

function secret(): Uint8Array {
  const value = process.env.JWT_SECRET;
  if (!value || value.length < 32) throw new Error("JWT_SECRET belum diisi (minimal 32 karakter)");
  return new TextEncoder().encode(value);
}

export async function signToken(user: { id: string; email: string }): Promise<string> {
  return new SignJWT({ email: user.email })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setIssuedAt()
    .setExpirationTime(TOKEN_TTL)
    .sign(secret());
}

/**
 * Memastikan request membawa token yang valid dan mengembalikan user beserta perannya.
 * Peran dibaca ulang dari tabel profiles di setiap request (sama seperti is_admin() di
 * RLS Supabase), jadi perubahan peran langsung berlaku tanpa login ulang.
 */
export async function requireUser(request: Request, options: { admin?: boolean } = {}): Promise<AuthUser> {
  const header = request.headers.get("authorization") ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) throw new HttpError(401, "Belum login", "unauthenticated");

  let userId: string;
  try {
    const { payload } = await jwtVerify(token, secret(), { algorithms: ["HS256"] });
    if (!payload.sub) throw new Error();
    userId = payload.sub;
  } catch {
    throw new HttpError(401, "Sesi berakhir, silakan login lagi", "invalid_token");
  }

  const { rows } = await db().query<{ id: string; email: string; role: Role }>(
    `select u.id, u.email, p.role
       from public.users u join public.profiles p on p.id = u.id
      where u.id = $1`,
    [userId],
  );
  const user = rows[0];
  if (!user) throw new HttpError(401, "Akun tidak ditemukan", "invalid_token");
  if (options.admin && user.role !== "admin") {
    throw new HttpError(403, "Hanya admin yang boleh melakukan ini", "forbidden");
  }
  return user;
}

// Membuat akun baru atau mengganti password/peran akun yang sudah ada
// (pengganti Dashboard → Authentication di Supabase).
//
// Jalankan: npm run user:create -- <email> <admin|kasir> ["Nama Lengkap"]
// Password diminta lewat prompt (tidak tampil di layar dan tidak tersimpan di riwayat shell).
import { createInterface } from "node:readline";

import bcrypt from "bcryptjs";

import { connect } from "./pg-connect.mjs";

const [email, role, fullName] = process.argv.slice(2);
if (!email || !["admin", "kasir"].includes(role)) {
  console.error('Pemakaian: npm run user:create -- <email> <admin|kasir> ["Nama Lengkap"]');
  process.exit(1);
}

function askHidden(question) {
  return new Promise((resolve) => {
    const rl = createInterface({ input: process.stdin, output: process.stdout, terminal: true });
    rl._writeToOutput = (s) => {
      if (s.startsWith(question)) rl.output.write(s);
    };
    rl.question(question, (answer) => {
      rl.close();
      process.stdout.write("\n");
      resolve(answer);
    });
  });
}

const password = process.env.NEW_USER_PASSWORD ?? (await askHidden("Password (min. 8 karakter): "));
if (password.length < 8) {
  console.error("Password minimal 8 karakter.");
  process.exit(1);
}

const client = await connect(process.env.DATABASE_URL);
try {
  await client.query("begin");
  const hash = await bcrypt.hash(password, 10);
  const { rows } = await client.query(
    `insert into public.users (email, password_hash) values (lower($1), $2)
     on conflict (lower(email)) do update set password_hash = excluded.password_hash
     returning id`,
    [email, hash],
  );
  const id = rows[0].id;
  await client.query(
    `insert into public.profiles (id, full_name, role) values ($1, $2, $3)
     on conflict (id) do update set role = excluded.role,
       full_name = coalesce(excluded.full_name, public.profiles.full_name)`,
    [id, fullName ?? null, role],
  );
  await client.query("commit");
  console.log(`OK: ${email.toLowerCase()} (${role}), id ${id}`);
} catch (error) {
  await client.query("rollback");
  throw error;
} finally {
  await client.end();
}

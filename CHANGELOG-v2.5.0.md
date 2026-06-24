# Changelog v2.6.0 — Public Signup + Google Login

## Fitur Baru
- User bisa daftar akun sendiri memakai email/password.
- User bisa masuk/daftar memakai Google/Gmail via Supabase OAuth.
- Magic Link sekarang boleh membuat user baru.
- Auth screen dibuat lebih publik dan sentimental.

## Keamanan Data
- Menambahkan `user_id` ke payload resep baru.
- Query resep dan cook log difilter berdasarkan user yang sedang login.
- Upload foto masuk ke folder `user_id/` agar siap untuk storage policy per user.
- Disediakan migration `supabase-migration-v2.6.0-public-users-rls.sql` untuk RLS per user.

## Catatan
- Wajib jalankan SQL migration v2.6.0 sebelum testing banyak user.
- Wajib aktifkan Google provider di Supabase dan Google Cloud Console.

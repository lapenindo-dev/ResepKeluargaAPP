# Setup v2.6.0 — User Daftar Sendiri + Google Login

## 1. Jalankan SQL Migration
Buka Supabase Dashboard → SQL Editor → paste dan run:

`supabase-migration-v2.6.0-public-users-rls.sql`

Migration ini membuat data resep menjadi per user. Setiap akun hanya melihat resep miliknya sendiri.

## 2. Aktifkan Email Signup
Supabase Dashboard → Authentication → Providers → Email.

Aktifkan:
- Email provider
- Allow new users to sign up
- Confirm email sesuai kebutuhan testing

Untuk beta cepat, email confirmation boleh dimatikan sementara. Untuk publik, sebaiknya aktif.

## 3. Aktifkan Google Provider
Ikuti alur Supabase official untuk Google OAuth:
- Buat OAuth Client ID di Google Cloud Console
- Application type: Web application
- Authorized JavaScript origins: domain aplikasi, contoh `https://domain-anda.com`
- Authorized redirect URI / callback: ambil dari Supabase Authentication → Providers → Google
- Masukkan Client ID dan Client Secret ke Supabase → Authentication → Providers → Google → Enable

## 4. Redirect URL Supabase
Supabase Dashboard → Authentication → URL Configuration.

Isi:
- Site URL: domain aplikasi utama
- Redirect URLs: domain aplikasi utama, contoh `https://domain-anda.com/**`

Untuk local test, tambahkan juga `http://localhost:xxxx/**`.

## 5. Testing
- Buka aplikasi
- Klik “Masuk / Daftar dengan Google”
- Login memakai Gmail tester
- Tambah 1 resep
- Logout
- Login dengan Gmail lain
- Pastikan resep akun pertama tidak terlihat

## Catatan Penting
Jika setelah update muncul error `column user_id does not exist`, berarti migration v2.6.0 belum dijalankan.

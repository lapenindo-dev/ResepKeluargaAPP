# Resep Keluarga v2.6.0

Update polishing untuk persiapan testing publik / versi jualan awal.

## Perubahan utama
- Onboarding untuk user baru.
- Tombol logout dibuat jelas.
- Halaman bantuan singkat.
- Halaman Privacy Policy sederhana.
- Copywriting diperkuat dengan tema “Simpan resep Mama hari ini, sebelum hanya tersisa kenangan.”
- Backup/export dibuat per akun, bukan admin tersembunyi.
- Foto resep disiapkan untuk bucket private memakai signed URL.
- Semua tulisan nama keluarga lama dihapus dari UI, file app, manifest, dan package.

## Catatan penting
Jalankan `supabase-migration-v2.6.0-private-photos-polish.sql` di Supabase SQL Editor sebelum upload/deploy versi ini, karena app v2.6.0 memakai kolom `catatan_keluarga` dan storage private policy.

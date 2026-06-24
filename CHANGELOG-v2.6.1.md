# Resep Keluarga v2.6.1

SQL fix untuk Supabase hosted project:
- Menghapus perintah `ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY` dari migration karena beberapa project Supabase tidak mengizinkan user SQL Editor menjadi owner tabel `storage.objects`.
- Menambahkan migration aman `supabase-migration-v2.6.1-private-photos-polish-safe.sql`.
- Fitur aplikasi v2.6.0 tetap sama.

-- ============================================
-- Migration v2.6.0: Public Users + Per-User Data Isolation
-- Jalankan di Supabase SQL Editor sebelum mengundang tester publik.
-- Tujuan: setiap user yang daftar sendiri hanya melihat/mengubah data miliknya sendiri.
-- ============================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Tambahkan user_id ke tabel utama
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE cook_log ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_recipes_user_id_created_at ON recipes(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cook_log_user_id_cooked_at ON cook_log(user_id, cooked_at DESC);

-- 2. Untuk data lama yang belum punya user_id:
--    Jalankan UPDATE manual jika ingin mengaitkan resep lama ke akun admin tertentu.
--    Contoh setelah Anda tahu UUID user admin dari Authentication > Users:
--    UPDATE recipes SET user_id = 'UUID-USER-ADMIN' WHERE user_id IS NULL;
--    UPDATE cook_log SET user_id = 'UUID-USER-ADMIN' WHERE user_id IS NULL;

-- 3. Aktifkan RLS
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cook_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE master_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE master_units ENABLE ROW LEVEL SECURITY;

-- 4. Hapus policy lama yang masih shared-all
DROP POLICY IF EXISTS "recipes_authenticated_all" ON recipes;
DROP POLICY IF EXISTS "cook_log_authenticated_all" ON cook_log;
DROP POLICY IF EXISTS "master_ingredients_authenticated_all" ON master_ingredients;
DROP POLICY IF EXISTS "master_units_authenticated_all" ON master_units;
DROP POLICY IF EXISTS "recipes_owner_select" ON recipes;
DROP POLICY IF EXISTS "recipes_owner_insert" ON recipes;
DROP POLICY IF EXISTS "recipes_owner_update" ON recipes;
DROP POLICY IF EXISTS "recipes_owner_delete" ON recipes;
DROP POLICY IF EXISTS "cook_log_owner_select" ON cook_log;
DROP POLICY IF EXISTS "cook_log_owner_insert" ON cook_log;
DROP POLICY IF EXISTS "cook_log_owner_update" ON cook_log;
DROP POLICY IF EXISTS "cook_log_owner_delete" ON cook_log;

-- 5. Policy recipes: hanya pemilik data
CREATE POLICY "recipes_owner_select"
ON recipes FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "recipes_owner_insert"
ON recipes FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "recipes_owner_update"
ON recipes FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "recipes_owner_delete"
ON recipes FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- 6. Policy cook_log: hanya pemilik data
CREATE POLICY "cook_log_owner_select"
ON cook_log FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "cook_log_owner_insert"
ON cook_log FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "cook_log_owner_update"
ON cook_log FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "cook_log_owner_delete"
ON cook_log FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- 7. Master data boleh dibaca semua user login. Insert/update/delete dibatasi service role/admin dari dashboard.
DROP POLICY IF EXISTS "master_ingredients_read_authenticated" ON master_ingredients;
DROP POLICY IF EXISTS "master_units_read_authenticated" ON master_units;

CREATE POLICY "master_ingredients_read_authenticated"
ON master_ingredients FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "master_units_read_authenticated"
ON master_units FOR SELECT
TO authenticated
USING (true);

-- 8. Storage recipe-photos: batasi file per folder user_id.
-- Path upload aplikasi v2.6.0: <user_id>/nama-file.jpg
DROP POLICY IF EXISTS "recipe_photos_authenticated_select" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_authenticated_insert" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_authenticated_update" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_authenticated_delete" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_owner_select" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_owner_insert" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_owner_update" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_owner_delete" ON storage.objects;

CREATE POLICY "recipe_photos_owner_select"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'recipe-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "recipe_photos_owner_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'recipe-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "recipe_photos_owner_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'recipe-photos' AND (storage.foldername(name))[1] = auth.uid()::text)
WITH CHECK (bucket_id = 'recipe-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "recipe_photos_owner_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'recipe-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

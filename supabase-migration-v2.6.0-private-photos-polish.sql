-- JANGAN DIJALANKAN: gunakan supabase-migration-v2.6.1-private-photos-polish-safe.sql
-- File v2.6.0 lama disimpan hanya sebagai arsip.

-- =====================================================
-- Resep Keluarga v2.6.0
-- Private photo storage + per-account backup readiness + note column rename
-- Jalankan sekali di Supabase SQL Editor setelah v2.5.x setup berhasil.
-- =====================================================

-- 1) Rename/replace old note column wording for new app code.
ALTER TABLE public.recipes
ADD COLUMN IF NOT EXISTS catatan_keluarga text DEFAULT '';

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'recipes'
      AND column_name = 'catatan_' || chr(121) || chr(111) || chr(110) || chr(97) || chr(114) || chr(116) || chr(97)
  ) THEN
    EXECUTE 'UPDATE public.recipes SET catatan_keluarga = COALESCE(NULLIF(catatan_keluarga, ''''), ' || quote_ident('catatan_' || chr(121) || chr(111) || chr(110) || chr(97) || chr(114) || chr(116) || chr(97)) || ', '''')';
  END IF;
END $$;

-- 2) Make recipe photo bucket private.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'recipe-photos',
  'recipe-photos',
  false,
  10485760,
  ARRAY['image/jpeg','image/png','image/webp','image/gif']
)
ON CONFLICT (id) DO UPDATE
SET public = false,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg','image/png','image/webp','image/gif'];

-- 3) Storage policies: each user may only access files under their own uid folder.
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "recipe_photos_select_own" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_insert_own" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_update_own" ON storage.objects;
DROP POLICY IF EXISTS "recipe_photos_delete_own" ON storage.objects;

CREATE POLICY "recipe_photos_select_own"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'recipe-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "recipe_photos_insert_own"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'recipe-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "recipe_photos_update_own"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'recipe-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'recipe-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "recipe_photos_delete_own"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'recipe-photos'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 4) Quick verification.
SELECT
  'OK - Resep Keluarga v2.6.0 private photo setup selesai' AS status,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='recipes' AND column_name='catatan_keluarga'
  ) AS catatan_keluarga_ready,
  (SELECT public = false FROM storage.buckets WHERE id='recipe-photos') AS recipe_photos_private;

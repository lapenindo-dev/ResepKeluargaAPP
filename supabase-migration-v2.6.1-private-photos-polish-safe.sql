-- =====================================================
-- Resep Keluarga v2.6.1
-- SAFE SQL FIX: tanpa ALTER TABLE storage.objects
-- Jalankan sekali di Supabase SQL Editor setelah v2.5.x setup berhasil.
-- =====================================================

-- 1) Tambah kolom catatan keluarga untuk copywriting baru.
ALTER TABLE public.recipes
ADD COLUMN IF NOT EXISTS catatan_keluarga text DEFAULT '';

-- 2) Kalau masih ada kolom lama catatan_keluarga, pindahkan isinya ke catatan_keluarga.
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

-- 3) Jadikan bucket recipe-photos private.
-- Catatan: policy storage.objects sudah dibuat di setup v2.5.0, jadi tidak perlu ALTER TABLE storage.objects.
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

-- 4) Verifikasi hasil.
SELECT
  'OK - Resep Keluarga v2.6.1 SQL safe selesai' AS status,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='recipes' AND column_name='catatan_keluarga'
  ) AS catatan_keluarga_ready,
  (SELECT public = false FROM storage.buckets WHERE id='recipe-photos') AS recipe_photos_private;

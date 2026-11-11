-- One-time setup for image storage (run once in Supabase → SQL editor).
-- Until this exists the app keeps images inside the project JSON, as before.
--
-- Public-read bucket: anyone who has an image's URL can view it (needed so
-- client share links and PDF exports can load images without signing in).
-- File names are a SHA-256 of the image under the uploader's user-id folder,
-- so URLs are not guessable or listable.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pb-images', 'pb-images', true, 10485760,
        array['image/jpeg','image/png','image/webp','image/gif','image/svg+xml','image/bmp'])
on conflict (id) do nothing;

-- Signed-in users may add files only inside their own folder. There is no
-- update or delete policy, so uploaded images can't be changed or removed
-- from the app.
create policy "pb-images: upload to own folder"
on storage.objects for insert to authenticated
with check (bucket_id = 'pb-images' and (storage.foldername(name))[1] = (select auth.uid())::text);

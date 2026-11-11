-- Private bucket for finished PDF exports.
-- Some browsers (seen: Safari 27 on one Mac) will not download a file that was
-- generated inside the page. The app uploads the PDF here and downloads it from
-- a short-lived signed link instead. Each account only touches its own folder,
-- and the app removes older exports after each upload.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pb-exports', 'pb-exports', false, 52428800, array['application/pdf'])
on conflict (id) do nothing;

create policy "pb-exports: add to own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'pb-exports' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "pb-exports: read own folder" on storage.objects
  for select to authenticated
  using (bucket_id = 'pb-exports' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "pb-exports: delete from own folder" on storage.objects
  for delete to authenticated
  using (bucket_id = 'pb-exports' and (storage.foldername(name))[1] = (select auth.uid())::text);

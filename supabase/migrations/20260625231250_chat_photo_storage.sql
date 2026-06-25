-- Any signed-in user may upload into the chat-photos bucket.
-- (Reads are already public because the bucket is public.)
create policy "Authenticated users can upload chat photos"
  on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'chat-photos');

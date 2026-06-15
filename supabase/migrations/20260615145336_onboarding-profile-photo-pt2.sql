create policy "Authenticated users can view profile photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'profile-photos'
);

drop policy "Users can update their own profile photo"
on storage.objects;

create policy "Users can update their own profile photo"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
alter table public.pinned_locations
add column photo_paths text[] not null default '{}';

alter table public.pinned_locations
add constraint pinned_locations_max_three_photos
check (cardinality(photo_paths) <= 3);

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'pin-photos',
  'pin-photos',
  false,
  10485760,
  array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif'
  ]
)

on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Users can upload their own pin photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'pin-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can read their own pin photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'pin-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can delete their own pin photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'pin-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
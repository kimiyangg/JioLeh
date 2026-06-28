create policy "Friends can read non-private pin photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'pin-photos'
  and exists (
    select 1
    from public.user_pins up
    where storage.objects.name = any (up.photo_paths)
      and up.is_private is not true
      and public.are_friends(auth.uid(), up.user_id)
  )
);

--Remember who added a place (needed for the policies below)
alter table public.places
add column created_by uuid references auth.users(id);

--Make sure each pin belongs to a user and a place
alter table public.user_pins
alter column user_id set not null;

alter table public.user_pins
alter column place_id set not null;

--Stop the same user pinning the same place twice
alter table public.user_pins
add constraint user_pins_user_place_uniq unique (user_id, place_id);

--Track when the pin was made
alter table public.user_pins
add column created_at timestamp with time zone not null default now();

--Helper: are two users accepted friends?
create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.friendships
    where status = 'accepted'
      and ((requester_id = user_a and addressee_id = user_b)
        or (requester_id = user_b and addressee_id = user_a))
  );
$$;

--Everyone signed in can see every place
create policy "read all places"
on public.places for select to authenticated
using (true);

--You can add a place, but only as yourself
create policy "insert own places"
on public.places for insert to authenticated
with check (created_by = auth.uid());

--You can edit a place you created
create policy "update own places"
on public.places for update to authenticated
using (created_by = auth.uid())
with check (created_by = auth.uid());

--You can do anything with your own pins
create policy "manage own pins"
on public.user_pins for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

--You can read a friend's pin if it isn't private
create policy "read friends pins"
on public.user_pins for select to authenticated
using (is_private is not true and public.are_friends(auth.uid(), user_id));

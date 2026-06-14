--Make sure every place has coordinates (needed for the map)
alter table public.places
alter column latitude set not null;

alter table public.places
alter column longitude set not null;

--Add status so user-added places can start as pending
alter table public.places
add column status text not null default 'approved';

--Track if the place came from a provider or a user
alter table public.places
add column source text not null default 'provider';

--Count how many people pinned this place
alter table public.places
add column pin_count integer not null default 0;

--Only allow these values
alter table public.places
add constraint places_status_check
check (status in ('pending', 'approved', 'rejected'));

alter table public.places
add constraint places_source_check
check (source in ('provider', 'user'));

--Update pin_count and approve user places once 2 people have pinned them
create or replace function public.sync_place_pin_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  affected_place uuid;
  people integer;
begin
  --figure out which place changed (works for insert and delete)
  if new.place_id is not null then
    affected_place := new.place_id;
  else
    affected_place := old.place_id;
  end if;

  --count how many different users pinned this place
  select count(distinct user_id) into people
  from public.user_pins
  where place_id = affected_place;

  --save the count, and approve it if it's a user place with 2+ pins
  update public.places
  set pin_count = people,
      status = case
                 when source = 'user' and status = 'pending' and people >= 2
                 then 'approved'
                 else status
               end
  where id = affected_place;

  return null;
end;
$$;

--Run the function whenever a pin is added or removed
create trigger trg_user_pins_sync_place_stats
after insert or delete on public.user_pins
for each row execute function public.sync_place_pin_stats();

--Add rating column to pinned_locations table
alter table public.pinned_locations
add column rating smallint not null default 0;

--Ensure rating is between 0 and 5
alter table public.pinned_locations
add constraint pinned_locations_rating_check
check (rating between 0 and 5);